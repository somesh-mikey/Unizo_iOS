//
//  OrderRepository.swift
//  Unizo_iOS
//
//  Data access layer for orders and order ratings using Firestore NoSQL.
//  Because NoSQL does not support native JOINS, creating an order executes
//  a Batch Write across `orders` and `order_items` collections, and fetching
//  makes parallel requests to populate items and nested product data.
//

import Foundation
import FirebaseFirestore

final class OrderRepository {

    private let db = Firestore.firestore()
    private let notificationRepository = NotificationRepository()

    init() { }

    // MARK: - Private Helpers

    private func getCurrentUserId() async throws -> String {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(domain: "OrderRepository", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        return userId
    }

    private func requireNetwork() throws {
        guard NetworkMonitor.shared.isReachable() else {
            throw NetworkError.noConnection
        }
    }

    private func decodeOrder(from snapshot: DocumentSnapshot) -> OrderDTO? {
        if var order = try? snapshot.data(as: OrderDTO.self) {
            if order.id == nil {
                order.id = snapshot.documentID
            }
            return order
        }

        guard let data = snapshot.data(),
              let userId = (data["user_id"] as? String) ?? (data["buyerId"] as? String),
              let status = data["status"] as? String else {
            let keys = snapshot.data()?.keys.map { String($0) } ?? []
            print("🟥 [DealDebug] OrderRepository.decodeOrder fallback failed orderId=\(snapshot.documentID), keys=\(keys)")
            return nil
        }
        
        let addressId = (data["address_id"] as? String) ?? "unknown_address"
        let paymentMethod = (data["payment_method"] as? String) ?? "Cash"

        let totalAmount: Double = {
            if let d = data["total_amount"] as? Double { return d }
            if let i = data["total_amount"] as? Int { return Double(i) }
            return 0
        }()

        let createdAt = (data["created_at"] as? String) ?? ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: 0))
        let instructions = data["instructions"] as? String
        let handoffCode = data["handoff_code"] as? String
        let handoffGeneratedAt = data["handoff_code_generated_at"] as? String

        print("🟨 [DealDebug] OrderRepository.decodeOrder used fallback for orderId=\(snapshot.documentID), created_at_present=\(data["created_at"] != nil)")

        return OrderDTO(
            id: nil,
            user_id: userId,
            address_id: addressId,
            status: status,
            total_amount: totalAmount,
            payment_method: paymentMethod,
            instructions: instructions,
            created_at: createdAt,
            handoff_code: handoffCode,
            handoff_code_generated_at: handoffGeneratedAt,
            items: nil,
            address: nil
        )
    }

    private func hasExistingDealRequest(
        buyerId: String,
        productId: String,
        disallowedStatuses: [String]
    ) async throws -> Bool {
        let orderIds: [String]

        do {
            let ordersSnapshot = try await db.collection("orders")
                .whereField("user_id", isEqualTo: buyerId)
                .whereField("status", in: disallowedStatuses)
                .getDocuments()
            orderIds = ordersSnapshot.documents.map { $0.documentID }
        } catch {
            // Fallback when a composite index is missing.
            print("🟨 [DealDebug] OrderRepository.hasExistingDealRequest primary orders query failed, fallback to user-only query: \(error)")
            let fallbackSnapshot = try await db.collection("orders")
                .whereField("user_id", isEqualTo: buyerId)
                .getDocuments()

            orderIds = fallbackSnapshot.documents
                .filter { doc in
                    let status = (doc.data()["status"] as? String) ?? ""
                    return disallowedStatuses.contains(status)
                }
                .map { $0.documentID }
        }

        guard !orderIds.isEmpty else { return false }

        for chunk in orderIds.chunked(into: 10) {
            do {
                let itemsSnapshot = try await db.collection("order_items")
                    .whereField("order_id", in: chunk)
                    .whereField("product_id", isEqualTo: productId)
                    .limit(to: 1)
                    .getDocuments()

                if !itemsSnapshot.documents.isEmpty {
                    return true
                }
            } catch {
                // Fallback when composite index for (order_id in, product_id ==) is missing.
                print("🟨 [DealDebug] OrderRepository.hasExistingDealRequest primary order_items query failed, fallback to order_id-only query: \(error)")
                let fallbackItemsSnapshot = try await db.collection("order_items")
                    .whereField("order_id", in: chunk)
                    .getDocuments()

                let hasMatch = fallbackItemsSnapshot.documents.contains { doc in
                    (doc.data()["product_id"] as? String) == productId
                }

                if hasMatch {
                    return true
                }
            }
        }

        return false
    }

    private struct StatusNotificationTemplate {
        let type: NotificationType
        let buyerMessageFormat: String
        let sellerMessageFormat: String
    }

    private static let statusNotificationTemplates: [OrderStatus: StatusNotificationTemplate] = [
        .confirmed: StatusNotificationTemplate(
            type: .orderAccepted,
            buyerMessageFormat: "%@ accepted your deal request.",
            sellerMessageFormat: "%@ confirmed this order."
        ),
        .cancelled: StatusNotificationTemplate(
            type: .orderRejected,
            buyerMessageFormat: "%@ rejected your deal request.",
            sellerMessageFormat: "%@ cancelled this order."
        ),
        .shipped: StatusNotificationTemplate(
            type: .orderShipped,
            buyerMessageFormat: "%@ marked your order as ready for handoff.",
            sellerMessageFormat: "%@ marked this order as ready for handoff."
        ),
        .delivered: StatusNotificationTemplate(
            type: .orderDelivered,
            buyerMessageFormat: "%@ marked your order as delivered.",
            sellerMessageFormat: "%@ confirmed delivery for this order."
        )
    ]

    private func fetchDisplayName(userId: String) async -> String {
        do {
            let doc = try await db.collection("users").document(userId).getDocument()
            if let user = try? doc.data(as: UserDTO.self) {
                let first = user.first_name ?? ""
                let last = user.last_name ?? ""
                let full = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
                if !full.isEmpty { return full }
                if let email = user.email, !email.isEmpty {
                    return email.components(separatedBy: "@").first ?? "A user"
                }
            }
        } catch {
            print("🟨 [DealDebug] OrderRepository.fetchDisplayName failed for userId=\(userId): \(error)")
        }
        return "A user"
    }

    private func fetchSellerIds(for orderItems: [OrderItemDTO]) async throws -> [String] {
        let productIds = Array(Set(orderItems.map { $0.product_id }))
        guard !productIds.isEmpty else { return [] }

        var sellerIds = Set<String>()
        for chunk in productIds.chunked(into: 10) {
            let productSnapshot = try await db.collection("products")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()

            for doc in productSnapshot.documents {
                if let sellerId = doc.data()["seller_id"] as? String, !sellerId.isEmpty {
                    sellerIds.insert(sellerId)
                }
            }
        }

        return Array(sellerIds)
    }

    private func sendStatusUpdateNotifications(orderId: String, status: OrderStatus, handoffCode: String? = nil) async {
        guard let template = Self.statusNotificationTemplates[status] else { return }

        do {
            let actorId = try await getCurrentUserId()
            let order = try await fetchOrder(id: orderId)
            let items = try await fetchOrderItems(orderId: orderId)
            let sellerIds = try await fetchSellerIds(for: items)
            let actorName = await fetchDisplayName(userId: actorId)

            var recipients = Set<String>()
            if status == .delivered {
                recipients.insert(order.user_id)
                sellerIds.forEach { recipients.insert($0) }
                recipients.remove(actorId)
            } else if sellerIds.contains(actorId) {
                recipients.insert(order.user_id)
            } else if actorId == order.user_id {
                sellerIds.forEach { recipients.insert($0) }
            } else {
                recipients.insert(order.user_id)
                sellerIds.forEach { recipients.insert($0) }
                recipients.remove(actorId)
            }

            print("🟪 [DealDebug] OrderRepository.sendStatusUpdateNotifications orderId=\(orderId), status=\(status.rawValue), actorId=\(actorId), recipients=\(Array(recipients))")

            for recipientId in recipients {
                let isBuyerRecipient = recipientId == order.user_id
                let messageFormat = isBuyerRecipient ? template.buyerMessageFormat : template.sellerMessageFormat
                var message = String(format: messageFormat, actorName)
                if status == .shipped,
                   isBuyerRecipient,
                   let handoffCode,
                   !handoffCode.isEmpty {
                    message += " Handoff code: \(handoffCode)."
                }

                let deeplinkPayload = DeeplinkPayload(
                    route: "order_details",
                    orderId: orderId,
                    sellerId: sellerIds.first
                )

                try await notificationRepository.createNotification(
                    recipientId: recipientId,
                    senderId: actorId,
                    orderId: orderId,
                    type: template.type,
                    title: actorName,
                    message: message,
                    deeplinkPayload: deeplinkPayload
                )
            }
        } catch {
            // Best effort: order updates should not fail if notification fails.
            print("🟥 [DealDebug] OrderRepository.sendStatusUpdateNotifications failed orderId=\(orderId), status=\(status.rawValue), error=\(error)")
        }
    }

    // MARK: - Order Creation

    func createOrder(
        addressId: String,
        items: [OrderItem],
        totalAmount: Double,
        paymentMethod: String,
        instructions: String?
    ) async throws -> String {
        try requireNetwork()
        let orderRef = db.collection("orders").document()
        let orderId = orderRef.documentID
        let userId  = try await getCurrentUserId()
        let createdAt = ISO8601DateFormatter().string(from: Date())

        print("🟪 [DealDebug] OrderRepository.createOrder start orderId=\(orderId), buyerId=\(userId), addressId=\(addressId), itemsCount=\(items.count), totalAmount=\(totalAmount), createdAt=\(createdAt)")

        let disallowedStatuses = [
            OrderStatus.pending.rawValue,
            OrderStatus.confirmed.rawValue,
            OrderStatus.shipped.rawValue,
            OrderStatus.delivered.rawValue
        ]

        // Prevent duplicate deals for the same product from the same buyer.
        var uniqueProducts: [(productId: String, productName: String)] = []
        var seenProductIds = Set<String>()
        for item in items {
            guard let productId = item.product.id, !productId.isEmpty else {
                throw NSError(domain: "OrderRepository", code: 422, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid product reference while placing deal."
                ])
            }

            if !seenProductIds.contains(productId) {
                seenProductIds.insert(productId)
                uniqueProducts.append((productId: productId, productName: item.product.name))
            }
        }

        for product in uniqueProducts {
            let alreadyPlaced = try await hasExistingDealRequest(
                buyerId: userId,
                productId: product.productId,
                disallowedStatuses: disallowedStatuses
            )

            print("🟪 [DealDebug] OrderRepository.createOrder duplicateCheck buyerId=\(userId), productId=\(product.productId), alreadyPlaced=\(alreadyPlaced)")

            if alreadyPlaced {
                let message = "You already placed a deal for \(product.productName)."
                print("🟥 [DealDebug] OrderRepository.createOrder blocked duplicate deal buyerId=\(userId), productId=\(product.productId)")
                throw NSError(domain: "OrderRepository", code: 409, userInfo: [
                    NSLocalizedDescriptionKey: message
                ])
            }
        }

        let orderPayload = OrderInsertDTO(
            id: orderId,
            user_id: userId,
            address_id: addressId,
            status: OrderStatus.pending.rawValue,
            total_amount: totalAmount,
            payment_method: paymentMethod,
            instructions: instructions,
            created_at: createdAt
        )

        let batch = db.batch()
        let orderData = try Firestore.Encoder().encode(orderPayload)
        batch.setData(orderData, forDocument: orderRef)

        var sellerItems: [String: [OrderItem]] = [:]

        for item in items {
            let itemRef = db.collection("order_items").document()
            print("🟪 [DealDebug] OrderRepository.createOrder item orderItemId=\(itemRef.documentID), productId=\(item.product.id ?? "nil"), sellerId=\(item.product.sellerId ?? "nil"), qty=\(item.quantity)")
            let itemPayload = OrderItemInsertDTO(
                id: itemRef.documentID,
                order_id: orderId,
                product_id: item.product.id ?? "",
                quantity: item.quantity,
                price_at_purchase: item.product.price,
                colour: item.product.colour,
                size: item.product.size
            )
            let itemData = try Firestore.Encoder().encode(itemPayload)
            batch.setData(itemData, forDocument: itemRef)
            
            if let sellerId = item.product.sellerId {
                sellerItems[sellerId, default: []].append(item)
            }
        }

        if sellerItems.isEmpty {
            print("🟥 [DealDebug] OrderRepository.createOrder sellerItems is EMPTY. No seller notification can be sent.")
        } else {
            let sellerSummary = sellerItems.map { "\($0.key):\($0.value.count)" }.joined(separator: ", ")
            print("🟪 [DealDebug] OrderRepository.createOrder sellerItems grouped -> \(sellerSummary)")
        }

        try await batch.commit()
        print("🟪 [DealDebug] OrderRepository.createOrder batch committed orderId=\(orderId)")
        print("📦 Order created — notifying \(sellerItems.count) seller(s)")

        let buyerName = try await fetchCurrentUserName()
        let notificationRepo = NotificationRepository()

        for (sellerId, sellerOrderItems) in sellerItems {
            let productNames = sellerOrderItems.map { $0.product.name }.joined(separator: ", ")
            let itemCount    = sellerOrderItems.count
            let message      = itemCount == 1
                ? "wants to place order for \(productNames)."
                : "wants to place order for \(itemCount) items."

            let deeplinkPayload = DeeplinkPayload(
                route: "confirm_order_seller",
                orderId: orderId,
                sellerId: sellerId
            )

            do {
                try await notificationRepo.createNotification(
                    recipientId: sellerId,
                    senderId: userId,
                    orderId: orderId,
                    type: .newOrder,
                    title: buyerName,
                    message: message,
                    deeplinkPayload: deeplinkPayload
                )
                print("🟪 [DealDebug] OrderRepository.createOrder notification sent sellerId=\(sellerId), orderId=\(orderId)")
            } catch {
                print("🟥 [DealDebug] OrderRepository.createOrder notification failed sellerId=\(sellerId), orderId=\(orderId), error=\(error)")
                throw error
            }
        }

        print("🟪 [DealDebug] OrderRepository.createOrder done orderId=\(orderId)")

        return orderId
    }

    private func fetchCurrentUserName() async throws -> String {
        let userId = try await getCurrentUserId()

        let doc = try await db.collection("users").document(userId).getDocument()
        guard let user = try? doc.data(as: UserDTO.self) else { return "A buyer" }

        let first = user.first_name ?? ""
        let last  = user.last_name  ?? ""

        if !first.isEmpty && !last.isEmpty  { return "\(first) \(last)" }
        if !first.isEmpty                   { return first }
        if !last.isEmpty                    { return last }
        if let email = user.email, !email.isEmpty {
            return email.components(separatedBy: "@").first ?? "A buyer"
        }
        return "A buyer"
    }

    // MARK: - Fetching Orders

    func fetchOrder(id: String) async throws -> OrderDTO {
        try requireNetwork()
        let snapshot = try await db.collection("orders").document(id).getDocument()
        guard let order = decodeOrder(from: snapshot) else {
            throw NSError(domain: "OrderRepository", code: 404, userInfo: nil)
        }
        return order
    }

    func fetchOrderWithDetails(id: String) async throws -> OrderDTO {
        try requireNetwork()
        let orderDoc = try await db.collection("orders").document(id).getDocument()
        guard var order = decodeOrder(from: orderDoc) else {
            throw NSError(domain: "OrderRepository", code: 404, userInfo: nil)
        }
        
        // 1. Fetch Address
        do {
            let addressDoc = try await db.collection("users").document(order.user_id).collection("addresses").document(order.address_id).getDocument()
            order.address = try? addressDoc.data(as: AddressDTO.self)
        } catch {
            print("⚠️ [DealDebug] OrderRepository failed to fetch address for order \(id): \(error.localizedDescription)")
            // Continue execution, do not throw, since the address may be hidden by security rules
        }
        
        // 2. Fetch Order Items
        var items = try await fetchOrderItems(orderId: id)
        
        // 3. Fetch Product Details + Sellers for each Item
        let productRepo = ProductRepository()
        for i in 0..<items.count {
            let pId = items[i].product_id
            items[i].product = try? await productRepo.fetchProduct(id: pId)
        }
        
        order.items = items
        return order
    }

    func fetchUserOrders() async throws -> [OrderDTO] {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        do {
            let snapshot = try await db.collection("orders")
                .whereField("user_id", isEqualTo: userId)
                .order(by: "created_at", descending: true)
                .getDocuments()
            return snapshot.documents.compactMap { try? $0.data(as: OrderDTO.self) }
        } catch {
            print("⚠️ fetchUserOrders index error, using fallback sorting: \(error.localizedDescription)")
            let fallbackSnapshot = try await db.collection("orders")
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()
            
            let sortedDocs = fallbackSnapshot.documents.sorted {
                let d1 = $0.data()["created_at"] as? String ?? ""
                let d2 = $1.data()["created_at"] as? String ?? ""
                return d1 > d2
            }
            return sortedDocs.compactMap { try? $0.data(as: OrderDTO.self) }
        }
    }

    func fetchOrderItems(orderId: String) async throws -> [OrderItemDTO] {
        try requireNetwork()
        let snapshot = try await db.collection("order_items")
            .whereField("order_id", isEqualTo: orderId)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: OrderItemDTO.self) }
    }

    func fetchUserOrdersWithItems() async throws -> [OrderDTO] {
        try requireNetwork()
        var orders = try await fetchUserOrders()
        let productRepo = ProductRepository()
        
        // Populate items in parallel
        await withTaskGroup(of: (Int, [OrderItemDTO]).self) { group in
            for i in 0..<orders.count {
                if let oId = orders[i].id {
                    group.addTask {
                        do {
                            var items = try await self.fetchOrderItems(orderId: oId)
                            for j in 0..<items.count {
                                let pId = items[j].product_id
                                items[j].product = try? await productRepo.fetchProduct(id: pId)
                            }
                            return (i, items)
                        } catch {
                            return (i, [])
                        }
                    }
                }
            }
            for await (index, fetchedItems) in group {
                orders[index].items = fetchedItems
            }
        }
        return orders
    }

    // MARK: - Status Updates

    func updateOrderStatus(orderId: String, status: OrderStatus) async throws {
        try requireNetwork()
        print("📝 Updating order \(orderId) → \(status.rawValue)")

        try await db.collection("orders").document(orderId).updateData([
            "status": status.rawValue
        ])

        await sendStatusUpdateNotifications(orderId: orderId, status: status)
    }

    func markReadyForHandoff(orderId: String, handoffCode: String) async throws {
        try requireNetwork()
        let now = ISO8601DateFormatter().string(from: Date())
        print("🤝 Marking order \(orderId) ready for handoff — code: \(handoffCode)")

        try await db.collection("orders").document(orderId).updateData([
            "status": OrderStatus.shipped.rawValue,
            "handoff_code": handoffCode,
            "handoff_code_generated_at": now
        ])
        await sendStatusUpdateNotifications(orderId: orderId, status: .shipped, handoffCode: handoffCode)
        print("✅ Order marked ready for handoff")
    }

    func verifyHandoffCode(orderId: String, enteredCode: String) async throws -> Bool {
        let order = try await fetchOrder(id: orderId)

        guard let storedCode = order.handoff_code else {
            print("❌ No handoff code found for order \(orderId)")
            return false
        }

        if storedCode == enteredCode {
            print("✅ Handoff code verified — marking as delivered")
            try await updateOrderStatus(orderId: orderId, status: .delivered)
            return true
        } else {
            print("❌ Handoff code mismatch: '\(enteredCode)' vs '\(storedCode)'")
            return false
        }
    }

    // MARK: - Ratings

    func submitOrderRating(
        orderId: String,
        ratedUserId: String,
        rating: Int,
        review: String? = nil
    ) async throws {
        try requireNetwork()
        guard rating >= 1 && rating <= 5 else {
            throw NSError(domain: "OrderRepository", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Rating must be between 1 and 5"
            ])
        }

        let raterId = try await getCurrentUserId()
        let ref = db.collection("order_ratings").document()
        let ratingPayload = OrderRatingInsertDTO(
            order_id: orderId,
            rater_id: raterId,
            rated_user_id: ratedUserId,
            rating: rating,
            review: review
        )

        let data = try Firestore.Encoder().encode(ratingPayload)
        try await ref.setData(data)
        print("✅ Rating submitted: \(rating)★ for user \(ratedUserId.prefix(8))")
        
        // Recalculate average and total
        try await recalculateUserRating(userId: ratedUserId)
        
        // Send notification to the rated user
        do {
            let raterName = await fetchDisplayName(userId: raterId)
            let deeplinkPayload = DeeplinkPayload(route: "order_details", orderId: orderId, sellerId: ratedUserId)
            try await notificationRepository.createNotification(
                recipientId: ratedUserId,
                senderId: raterId,
                orderId: orderId,
                type: .newRating,
                title: "New Rating",
                message: "\(raterName) gave you a \(rating)-star rating.",
                deeplinkPayload: deeplinkPayload
            )
        } catch {
            print("⚠️ Failed to send rating notification: \(error)")
        }
    }

    func fetchOrderRating(orderId: String, raterId: String) async throws -> OrderRatingDTO? {
        let snapshot = try await db.collection("order_ratings")
            .whereField("order_id", isEqualTo: orderId)
            .whereField("rater_id", isEqualTo: raterId)
            .getDocuments()

        return snapshot.documents.first.flatMap { try? $0.data(as: OrderRatingDTO.self) }
    }

    func fetchUserRatings(userId: String) async throws -> [OrderRatingDTO] {
        let snapshot = try await db.collection("order_ratings")
            .whereField("rated_user_id", isEqualTo: userId)
            .order(by: "created_at", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: OrderRatingDTO.self) }
    }

    struct UserRatingSummary: Decodable {
        let average_rating: Double?
        let total_ratings: Int?
    }

    func fetchUserRatingSummary(userId: String) async throws -> UserRatingSummary {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        guard let data = snapshot.data() else {
            return UserRatingSummary(average_rating: 0, total_ratings: 0)
        }
        return UserRatingSummary(
            average_rating: data["average_rating"] as? Double,
            total_ratings: data["total_ratings"] as? Int
        )
    }

    func updateOrderRating(ratingId: String, newRating: Int, newReview: String? = nil) async throws {
        guard newRating >= 1 && newRating <= 5 else {
            throw NSError(domain: "OrderRepository", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Rating must be between 1 and 5"
            ])
        }

        try await db.collection("order_ratings").document(ratingId).updateData([
            "rating": newRating,
            "review": newReview ?? ""
        ])
        print("✅ Rating updated: \(newRating)★")
    }

    func deleteOrderRating(ratingId: String) async throws {
        try await db.collection("order_ratings").document(ratingId).delete()
        print("✅ Rating deleted")
    }

    func canRateOrder(_ orderId: String) async throws -> Bool {
        do {
            let order = try await fetchOrder(id: orderId)
            guard order.status == "delivered" else { return false }

            let currentUserId = try await getCurrentUserId()
            let isBuyer  = order.user_id == currentUserId
            let isSeller = try await isUserSellerInOrder(orderId, userId: currentUserId)
            return isBuyer || isSeller
        } catch {
            return false
        }
    }

    private func isUserSellerInOrder(_ orderId: String, userId: String) async throws -> Bool {
        let items = try await fetchOrderItems(orderId: orderId)
        
        for item in items {
            let productId = item.product_id
            let productDoc = try await db.collection("products").document(productId).getDocument()
            if let sellerId = productDoc.data()?["seller_id"] as? String, sellerId == userId {
                return true
            }
        }
        return false
    }
    func getActiveOrderId(for productId: String) async throws -> String? {
        let itemsSnapshot = try await db.collection("order_items")
            .whereField("product_id", isEqualTo: productId)
            .getDocuments()

        for doc in itemsSnapshot.documents {
            if let orderId = doc.data()["order_id"] as? String {
                let orderDoc = try await db.collection("orders").document(orderId).getDocument()
                if let statusString = orderDoc.data()?["status"] as? String, let status = OrderStatus(rawValue: statusString) {
                    if status != .cancelled {
                        return orderId
                    }
                }
            }
        }
        return nil
    }

}
extension OrderRepository {
    func confirmOrderAndGenerateHandoff(orderId: String, handoffCode: String) async throws {
        try requireNetwork()
        print("📝 Confirming order \(orderId) and generating handoff code \(handoffCode)")

        let now = ISO8601DateFormatter().string(from: Date())
        try await db.collection("orders").document(orderId).updateData([
            "status": OrderStatus.confirmed.rawValue,
            "handoff_code": handoffCode,
            "handoff_code_generated_at": now
        ])

        do {
            let itemsSnapshot = try await db.collection("order_items")
                .whereField("order_id", isEqualTo: orderId)
                .getDocuments()
            
            let productRepo = ProductRepository()
            for doc in itemsSnapshot.documents {
                if let productId = doc.data()["product_id"] as? String {
                    let quantity = doc.data()["quantity"] as? Int ?? 1
                    try await productRepo.markProductAsSold(productId: productId, quantitySold: quantity)
                    print("📉 Deducted \(quantity) from product \(productId)")
                }
            }
        } catch {
            print("⚠️ Failed to update product inventory after confirmation: \(error.localizedDescription)")
        }

        await sendStatusUpdateNotifications(orderId: orderId, status: .confirmed, handoffCode: handoffCode)
    }

    private func recalculateUserRating(userId: String) async throws {
        let snapshot = try await db.collection("order_ratings")
            .whereField("rated_user_id", isEqualTo: userId)
            .getDocuments()

        let ratings = snapshot.documents.compactMap { try? $0.data(as: OrderRatingDTO.self) }
        let totalRatings = ratings.count
        let averageRating = totalRatings > 0 ? ratings.reduce(0.0) { $0 + Double($1.rating) } / Double(totalRatings) : 0.0

        try await db.collection("users").document(userId).setData([
            "average_rating": averageRating,
            "total_ratings": totalRatings
        ], merge: true)
        print("✅ Recalculated rating for \(userId.prefix(8)): average \(averageRating), total \(totalRatings)")
    }
}
