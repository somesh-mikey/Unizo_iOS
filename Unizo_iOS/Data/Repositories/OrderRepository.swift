//
//  OrderRepository.swift
//  Unizo_iOS
//
//  Created by Soham on 22/01/26.
//

import Foundation
import Supabase

final class OrderRepository {

    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> UUID {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(domain: "OrderRepository", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        return userId
    }

    // MARK: - Create Order
    func createOrder(
        addressId: UUID,
        items: [OrderItem],
        totalAmount: Double,
        paymentMethod: String,
        instructions: String?
    ) async throws -> UUID {
        let orderId = UUID()
        let userId = try await getCurrentUserId()

        // Create the order with 'pending' status - will become 'confirmed' when seller accepts
        let orderPayload = OrderInsertDTO(
            id: orderId,
            user_id: userId,
            address_id: addressId,
            status: OrderStatus.pending.rawValue,
            total_amount: totalAmount,
            payment_method: paymentMethod,
            instructions: instructions
        )

        try await client
            .from("orders")
            .insert(orderPayload)
            .execute()

        // Create order items
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

            try await client
                .from("order_items")
                .insert(itemPayload)
                .execute()
        }

        // MARK: - Create Notifications Per Seller
        // Group items by seller_id
        var sellerItems: [UUID: [OrderItem]] = [:]
        for item in items {
            guard let sellerId = item.product.sellerId else {
                print("⚠️ Product \(item.product.name) has no sellerId - skipping notification")
                continue
            }
            sellerItems[sellerId, default: []].append(item)
        }

        print("📦 Order created - preparing notifications for \(sellerItems.count) seller(s)")
        print("📦 Buyer (current user) ID: \(userId.uuidString)")

        // Get buyer name for notification
        let buyerName = try await fetchCurrentUserName()
        print("📦 Buyer name: \(buyerName)")

        // Create one notification per seller
        let notificationRepo = NotificationRepository(client: client)
        for (sellerId, sellerOrderItems) in sellerItems {
            print("📦 Processing notification for seller: \(sellerId.uuidString)")

            let productNames = sellerOrderItems.map { $0.product.name }.joined(separator: ", ")
            let itemCount = sellerOrderItems.count
            let message = itemCount == 1
                ? "wants to place order for \(productNames)."
                : "wants to place order for \(itemCount) items."

            // Build deeplink payload for navigation
            let deeplinkPayload = DeeplinkPayload(
                route: "confirm_order_seller",
                orderId: orderId,
                sellerId: sellerId
            )

            try await notificationRepo.createNotification(
                recipientId: sellerId,      // Seller receives
                senderId: userId,           // Buyer triggered
                orderId: orderId,
                type: .newOrder,
                title: buyerName,
                message: message,
                deeplinkPayload: deeplinkPayload
            )
        }

        return orderId
    }

    // MARK: - Fetch Current User Name
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

        let firstName = user.first_name ?? ""
        let lastName = user.last_name ?? ""

        if !firstName.isEmpty && !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        } else if !firstName.isEmpty {
            return firstName
        } else if !lastName.isEmpty {
            return lastName
        } else if let email = user.email, !email.isEmpty {
            // Use part before @ as display name
            return email.components(separatedBy: "@").first ?? "A buyer"
        } else {
            return "A buyer"
        }
    }

    // MARK: - Fetch Order by ID
    func fetchOrder(id: UUID) async throws -> OrderDTO {
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

    // MARK: - Fetch Order with Items and Address
    func fetchOrderWithDetails(id: UUID) async throws -> OrderDTO {
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

    // MARK: - Fetch User Orders
    func fetchUserOrders() async throws -> [OrderDTO] {
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

    // MARK: - Fetch Order Items
    func fetchOrderItems(orderId: UUID) async throws -> [OrderItemDTO] {
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

    // MARK: - Fetch User Orders With Items
    func fetchUserOrdersWithItems() async throws -> [OrderDTO] {
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

    // MARK: - Update Order Status
    func updateOrderStatus(orderId: UUID, status: OrderStatus) async throws {
        struct StatusUpdate: Encodable {
            let status: String
        }

        print("📝 Updating order status:")
        print("   - Order ID: \(orderId.uuidString)")
        print("   - New Status: \(status.rawValue)")

        try await client
            .from("orders")
            .update(StatusUpdate(status: status.rawValue))
            .eq("id", value: orderId.uuidString)
            .execute()

        print("✅ Order status updated successfully to: \(status.rawValue)")

        // Verify the update
        let updatedOrder = try await fetchOrder(id: orderId)
        print("🔍 Verification - Order status in DB: \(updatedOrder.status)")
    }

    // MARK: - Mark Ready for Handoff (Seller Action)
    func markReadyForHandoff(orderId: UUID, handoffCode: String) async throws {
        struct HandoffUpdate: Encodable {
            let status: String
            let handoff_code: String
            let handoff_code_generated_at: String
        }

        let now = ISO8601DateFormatter().string(from: Date())

        print("🤝 Marking order ready for handoff:")
        print("   - Order ID: \(orderId.uuidString)")
        print("   - Handoff Code: \(handoffCode)")

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

    // MARK: - Verify Handoff Code (Seller Action)
    func verifyHandoffCode(orderId: UUID, enteredCode: String) async throws -> Bool {
        let order = try await fetchOrder(id: orderId)

        guard let storedCode = order.handoff_code else {
            print("❌ No handoff code found for order: \(orderId.uuidString)")
            return false
        }

        if storedCode == enteredCode {
            print("✅ Handoff code verified - marking as delivered")
            try await updateOrderStatus(orderId: orderId, status: .delivered)
            return true
        } else {
            print("❌ Handoff code mismatch: entered '\(enteredCode)' vs stored '\(storedCode)'")
            return false
        }
    }

    // MARK: - Submit Order Rating
    /// Submits a rating for a user after an order is completed
    /// - Parameters:
    ///   - orderId: The order ID
    ///   - ratedUserId: The user being rated
    ///   - rating: Rating from 1 to 5 stars
    ///   - review: Optional written review
    func submitOrderRating(
        orderId: UUID,
        ratedUserId: UUID,
        rating: Int,
        review: String? = nil
    ) async throws {
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

        try await client
            .from("order_ratings")
            .insert(ratingPayload)
            .execute()

        print("✅ Rating submitted: \(rating) stars for user \(ratedUserId.uuidString.prefix(8))")
    }

    // MARK: - Fetch Order Rating (if exists)
    /// Fetches an existing rating for a given order and rater
    func fetchOrderRating(orderId: UUID, raterId: UUID) async throws -> OrderRatingDTO? {
        let response = try await client
            .from("order_ratings")
            .select()
            .eq("order_id", value: orderId.uuidString)
            .eq("rater_id", value: raterId.uuidString)
            .single()
            .execute()

        let data = try JSONDecoder().decode(OrderRatingDTO.self, from: response.data)
        return data
    }

    // MARK: - Fetch All Ratings for a User
    /// Fetches all ratings given to a specific user (seller or buyer)
    func fetchUserRatings(userId: UUID) async throws -> [OrderRatingDTO] {
        let response = try await client
            .from("order_ratings")
            .select()
            .eq("rated_user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()

        let data = try JSONDecoder().decode([OrderRatingDTO].self, from: response.data)
        return data
    }

    // MARK: - Fetch User Rating Summary
    /// Fetches average rating and total ratings count for a user
    struct UserRatingSummary: Decodable {
        let average_rating: Double?
        let total_ratings: Int?

        enum CodingKeys: String, CodingKey {
            case average_rating
            case total_ratings
        }
    }

    func fetchUserRatingSummary(userId: UUID) async throws -> UserRatingSummary {
        let response = try await client
            .from("users")
            .select("average_rating, total_ratings")
            .eq("id", value: userId.uuidString)
            .single()
            .execute()

        let data = try JSONDecoder().decode(UserRatingSummary.self, from: response.data)
        return data
    }

    // MARK: - Update Rating
    /// Allows updating a rating (only the review and rating itself)
    func updateOrderRating(
        ratingId: UUID,
        newRating: Int,
        newReview: String? = nil
    ) async throws {
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
            .update(RatingUpdate(
                rating: newRating,
                review: newReview ?? ""
            ))
            .eq("id", value: ratingId.uuidString)
            .execute()

        print("✅ Rating updated: \(newRating) stars")
    }

    // MARK: - Delete Rating
    /// Allows deleting a rating (only by the user who created it)
    func deleteOrderRating(ratingId: UUID) async throws {
        try await client
            .from("order_ratings")
            .delete()
            .eq("id", value: ratingId.uuidString)
            .execute()

        print("✅ Rating deleted")
    }

    // MARK: - Check if User Can Rate Order
    /// Checks if the current user can rate a specific order
    /// (user must be buyer or seller in the order and order must be delivered)
    func canRateOrder(_ orderId: UUID) async throws -> Bool {
        do {
            let order = try await fetchOrder(id: orderId)
            
            // Order must be delivered
            guard order.status == "delivered" else {
                return false
            }

            let currentUserId = try await getCurrentUserId()

            // Check if user is buyer or seller
            let isBuyer = order.user_id == currentUserId
            let isSeller = try await isUserSellerInOrder(orderId, userId: currentUserId)

            return isBuyer || isSeller
        } catch {
            return false
        }
    }

    // MARK: - Helper: Check if user is seller in order
    private func isUserSellerInOrder(_ orderId: UUID, userId: UUID) async throws -> Bool {
        let response = try await client
            .from("order_items")
            .select("product_id")
            .eq("order_id", value: orderId.uuidString)
            .execute()

        struct OrderItem: Decodable {
            let product_id: UUID
        }

        let items = try JSONDecoder().decode([OrderItem].self, from: response.data)

        for item in items {
            let productResponse = try await client
                .from("products")
                .select("seller_id")
                .eq("id", value: item.product_id.uuidString)
                .single()
                .execute()

            struct Product: Decodable {
                let seller_id: UUID
            }

            let product = try JSONDecoder().decode(Product.self, from: productResponse.data)
            if product.seller_id == userId {
                return true
            }
        }

        return false
    }
}
