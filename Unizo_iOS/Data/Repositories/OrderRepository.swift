//
//  OrderRepository.swift
//  Unizo_iOS
//
//  Created by Soham on 22/01/26.
//
//  Data access layer for orders and order ratings. Handles the full
//  lifecycle: creation, status updates, handoff verification, and
//  post-delivery ratings.
//

import Foundation
import Supabase

final class OrderRepository {

    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Private Helpers

    private func getCurrentUserId() async throws -> UUID {
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

    /// Creates the order record, inserts order items, then sends a notification
    /// to each seller involved. Returns the new order's UUID.
    func createOrder(
        addressId: UUID,
        items: [OrderItem],
        totalAmount: Double,
        paymentMethod: String,
        instructions: String?
    ) async throws -> UUID {
        try requireNetwork()
        let orderId = UUID()
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

        try await client.from("orders").insert(orderPayload).execute()

        for item in items {
            let itemPayload = OrderItemInsertDTO(
                id: UUID(),
                order_id: orderId,
                product_id: item.product.id,
                quantity: item.quantity,
                price_at_purchase: item.product.price,
                colour: item.product.colour,
                size: item.product.size
            )
            try await client.from("order_items").insert(itemPayload).execute()
        }

        // Group by seller so each seller gets exactly one notification
        var sellerItems: [UUID: [OrderItem]] = [:]
        for item in items {
            guard let sellerId = item.product.sellerId else {
                print("⚠️ Product \(item.product.name) has no sellerId — skipping notification")
                continue
            }
            sellerItems[sellerId, default: []].append(item)
        }

        print("📦 Order created — notifying \(sellerItems.count) seller(s)")

        let buyerName = try await fetchCurrentUserName()
        let notificationRepo = NotificationRepository(client: client)

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

    /// Returns a display name from the user's profile. Falls back to email
    /// prefix, then "A buyer".
    private func fetchCurrentUserName() async throws -> String {
        let userId = try await getCurrentUserId()

        struct UserName: Codable {
            let first_name: String?
            let last_name: String?
            let email: String?
        }

        let user: UserName = try await client
            .from("users")
            .select("first_name, last_name, email")
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

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

    func fetchOrder(id: UUID) async throws -> OrderDTO {
        try requireNetwork()
        let response: OrderDTO = try await client
            .from("orders")
            .select("""
                id,
                user_id,
                address_id,
                status,
                total_amount,
                payment_method,
                instructions,
                created_at,
                handoff_code,
                handoff_code_generated_at
            """)
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value

        return response
    }

    func fetchOrderWithDetails(id: UUID) async throws -> OrderDTO {
        try requireNetwork()
        let response: OrderDTO = try await client
            .from("orders")
            .select("""
                id,
                user_id,
                address_id,
                status,
                total_amount,
                payment_method,
                instructions,
                created_at,
                handoff_code,
                handoff_code_generated_at,
                items:order_items(
                    id,
                    order_id,
                    product_id,
                    quantity,
                    price_at_purchase,
                    colour,
                    size,
                    product:products(
                        id,
                        title,
                        description,
                        price,
                        image_url,
                        is_negotiable,
                        views_count,
                        is_active,
                        rating,
                        colour,
                        category,
                        size,
                        condition,
                        seller:users!seller_id(id, first_name, last_name, email)
                    )
                ),
                address:addresses(
                    id,
                    user_id,
                    name,
                    phone,
                    line1,
                    city,
                    state,
                    postal_code,
                    country,
                    is_default
                )
            """)
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value

        return response
    }

    func fetchUserOrders() async throws -> [OrderDTO] {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let response: [OrderDTO] = try await client
            .from("orders")
            .select("""
                id,
                user_id,
                address_id,
                status,
                total_amount,
                payment_method,
                instructions,
                created_at,
                handoff_code,
                handoff_code_generated_at
            """)
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    func fetchOrderItems(orderId: UUID) async throws -> [OrderItemDTO] {
        try requireNetwork()
        let response: [OrderItemDTO] = try await client
            .from("order_items")
            .select("""
                id,
                order_id,
                product_id,
                quantity,
                price_at_purchase,
                colour,
                size,
                product:products(
                    id,
                    title,
                    description,
                    price,
                    image_url,
                    is_negotiable,
                    views_count,
                    is_active,
                    rating,
                    colour,
                    category,
                    size,
                    condition,
                    seller:users!seller_id(id, first_name, last_name, email)
                )
            """)
            .eq("order_id", value: orderId.uuidString)
            .execute()
            .value

        return response
    }

    func fetchUserOrdersWithItems() async throws -> [OrderDTO] {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let response: [OrderDTO] = try await client
            .from("orders")
            .select("""
                id,
                user_id,
                address_id,
                status,
                total_amount,
                payment_method,
                instructions,
                created_at,
                handoff_code,
                handoff_code_generated_at,
                items:order_items(
                    id,
                    order_id,
                    product_id,
                    quantity,
                    price_at_purchase,
                    colour,
                    size,
                    product:products(
                        id,
                        title,
                        description,
                        price,
                        image_url,
                        is_negotiable,
                        views_count,
                        is_active,
                        rating,
                        colour,
                        category,
                        size,
                        condition
                    )
                )
            """)
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Status Updates

    func updateOrderStatus(orderId: UUID, status: OrderStatus) async throws {
        try requireNetwork()
        struct StatusUpdate: Encodable { let status: String }

        print("📝 Updating order \(orderId.uuidString) → \(status.rawValue)")

        try await client
            .from("orders")
            .update(StatusUpdate(status: status.rawValue))
            .eq("id", value: orderId.uuidString)
            .execute()

        let updatedOrder = try await fetchOrder(id: orderId)
        print("🔍 Verified status in DB: \(updatedOrder.status)")
    }

    /// Sets status to `shipped`, stores the handoff code and generation timestamp.
    func markReadyForHandoff(orderId: UUID, handoffCode: String) async throws {
        try requireNetwork()
        struct HandoffUpdate: Encodable {
            let status: String
            let handoff_code: String
            let handoff_code_generated_at: String
        }

        let now = ISO8601DateFormatter().string(from: Date())

        print("🤝 Marking order \(orderId.uuidString) ready for handoff — code: \(handoffCode)")

        try await client
            .from("orders")
            .update(HandoffUpdate(
                status: OrderStatus.shipped.rawValue,
                handoff_code: handoffCode,
                handoff_code_generated_at: now
            ))
            .eq("id", value: orderId.uuidString)
            .execute()

        print("✅ Order marked ready for handoff")
    }

    /// Compares `enteredCode` against the stored handoff code.
    /// If they match, transitions the order to `.delivered` and returns `true`.
    func verifyHandoffCode(orderId: UUID, enteredCode: String) async throws -> Bool {
        let order = try await fetchOrder(id: orderId)

        guard let storedCode = order.handoff_code else {
            print("❌ No handoff code found for order \(orderId.uuidString)")
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

    /// Submits a 1–5 star rating for a user after order completion.
    /// `review` is optional freeform text.
    func submitOrderRating(
        orderId: UUID,
        ratedUserId: UUID,
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

        let ratingPayload = OrderRatingInsertDTO(
            order_id: orderId,
            rater_id: raterId,
            rated_user_id: ratedUserId,
            rating: rating,
            review: review
        )

        try await client.from("order_ratings").insert(ratingPayload).execute()
        print("✅ Rating submitted: \(rating)★ for user \(ratedUserId.uuidString.prefix(8))")
    }

    func fetchOrderRating(orderId: UUID, raterId: UUID) async throws -> OrderRatingDTO? {
        let response = try await client
            .from("order_ratings")
            .select()
            .eq("order_id", value: orderId.uuidString)
            .eq("rater_id", value: raterId.uuidString)
            .single()
            .execute()

        return try JSONDecoder().decode(OrderRatingDTO.self, from: response.data)
    }

    func fetchUserRatings(userId: UUID) async throws -> [OrderRatingDTO] {
        let response = try await client
            .from("order_ratings")
            .select()
            .eq("rated_user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()

        return try JSONDecoder().decode([OrderRatingDTO].self, from: response.data)
    }

    /// Reads `average_rating` and `total_ratings` from the `users` table
    /// (these are denormalised columns updated by a DB trigger).
    struct UserRatingSummary: Decodable {
        let average_rating: Double?
        let total_ratings: Int?
    }

    func fetchUserRatingSummary(userId: UUID) async throws -> UserRatingSummary {
        let response = try await client
            .from("users")
            .select("average_rating, total_ratings")
            .eq("id", value: userId.uuidString)
            .single()
            .execute()

        return try JSONDecoder().decode(UserRatingSummary.self, from: response.data)
    }

    func updateOrderRating(ratingId: UUID, newRating: Int, newReview: String? = nil) async throws {
        struct RatingUpdate: Encodable {
            let rating: Int
            let review: String
        }

        guard newRating >= 1 && newRating <= 5 else {
            throw NSError(domain: "OrderRepository", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Rating must be between 1 and 5"
            ])
        }

        try await client
            .from("order_ratings")
            .update(RatingUpdate(rating: newRating, review: newReview ?? ""))
            .eq("id", value: ratingId.uuidString)
            .execute()

        print("✅ Rating updated: \(newRating)★")
    }

    func deleteOrderRating(ratingId: UUID) async throws {
        try await client
            .from("order_ratings")
            .delete()
            .eq("id", value: ratingId.uuidString)
            .execute()

        print("✅ Rating deleted")
    }

    /// Returns `true` if the current user is the buyer or seller of `orderId`
    /// and the order status is `delivered`.
    func canRateOrder(_ orderId: UUID) async throws -> Bool {
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

    private func isUserSellerInOrder(_ orderId: UUID, userId: UUID) async throws -> Bool {
        let response = try await client
            .from("order_items")
            .select("product_id")
            .eq("order_id", value: orderId.uuidString)
            .execute()

        struct OrderItem: Decodable { let product_id: UUID }

        let items = try JSONDecoder().decode([OrderItem].self, from: response.data)

        for item in items {
            let productResponse = try await client
                .from("products")
                .select("seller_id")
                .eq("id", value: item.product_id.uuidString)
                .single()
                .execute()

            struct Product: Decodable { let seller_id: UUID }

            let product = try JSONDecoder().decode(Product.self, from: productResponse.data)
            if product.seller_id == userId { return true }
        }

        return false
    }
}
