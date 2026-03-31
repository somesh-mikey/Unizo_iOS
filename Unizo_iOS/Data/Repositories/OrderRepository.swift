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

        let orderPayload = OrderInsertDTO(
            id: orderId,
            user_id: userId,
            address_id: addressId,
            status: OrderStatus.pending.rawValue,
            total_amount: totalAmount,
            payment_method: paymentMethod,
            instructions: instructions
        )

        let batch = db.batch()
        let orderData = try Firestore.Encoder().encode(orderPayload)
        batch.setData(orderData, forDocument: orderRef)

        var sellerItems: [String: [OrderItem]] = [:]

        for item in items {
            let itemRef = db.collection("order_items").document()
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

        try await batch.commit()
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

            try await notificationRepo.createNotification(
                recipientId: sellerId,
                senderId: userId,
                orderId: orderId,
                type: .newOrder,
                title: buyerName,
                message: message,
                deeplinkPayload: deeplinkPayload
            )
        }

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
        guard let order = try? snapshot.data(as: OrderDTO.self) else {
            throw NSError(domain: "OrderRepository", code: 404, userInfo: nil)
        }
        return order
    }

    func fetchOrderWithDetails(id: String) async throws -> OrderDTO {
        try requireNetwork()
        let orderDoc = try await db.collection("orders").document(id).getDocument()
        guard var order = try? orderDoc.data(as: OrderDTO.self) else {
            throw NSError(domain: "OrderRepository", code: 404, userInfo: nil)
        }
        
        // 1. Fetch Address
        let addressDoc = try await db.collection("users").document(order.user_id).collection("addresses").document(order.address_id).getDocument()
        order.address = try? addressDoc.data(as: AddressDTO.self)
        
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

        let snapshot = try await db.collection("orders")
            .whereField("user_id", isEqualTo: userId)
            .order(by: "created_at", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: OrderDTO.self) }
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
        let userId = try await getCurrentUserId()

        let snapshot = try await db.collection("orders")
            .whereField("user_id", isEqualTo: userId)
            .order(by: "created_at", descending: true)
            .getDocuments()

        var orders = snapshot.documents.compactMap { try? $0.data(as: OrderDTO.self) }
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
}
