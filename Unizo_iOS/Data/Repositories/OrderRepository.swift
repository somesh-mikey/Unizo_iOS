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
        items: [CartItem],
        totalAmount: Double,
        paymentMethod: String,
        instructions: String?
    ) async throws -> UUID {
        let orderId = UUID()
        let userId = try await getCurrentUserId()

        // Create the order
        let orderPayload = OrderInsertDTO(
            id: orderId,
            user_id: userId,
            address_id: addressId,
            status: OrderStatus.confirmed.rawValue,
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
        var sellerItems: [UUID: [CartItem]] = [:]
        for item in items {
            guard let sellerId = item.product.sellerId else { continue }
            sellerItems[sellerId, default: []].append(item)
        }

        // Get buyer name for notification
        let buyerName = try await fetchCurrentUserName()

        // Create one notification per seller
        let notificationRepo = NotificationRepository(client: client)
        for (sellerId, sellerCartItems) in sellerItems {
            let productNames = sellerCartItems.map { $0.product.name }.joined(separator: ", ")
            let itemCount = sellerCartItems.count
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
        }

        let user: UserName = try await client
            .from("users")
            .select("first_name, last_name")
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
                created_at
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
                        seller:users!seller_id(id, first_name, last_name)
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
                created_at
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
                    seller:users!seller_id(id, first_name, last_name)
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

        try await client
            .from("orders")
            .update(StatusUpdate(status: status.rawValue))
            .eq("id", value: orderId.uuidString)
            .execute()
    }
}
