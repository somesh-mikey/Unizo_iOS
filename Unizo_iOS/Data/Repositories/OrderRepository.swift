//
//  OrderRepository.swift
//  Unizo_iOS
//
//  Created by Claude on 22/01/26.
//

import Foundation
import Supabase

final class OrderRepository {

    private let client: SupabaseClient

    init(client: SupabaseClient = supabase) {
        self.client = client
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

        // Create the order
        let orderPayload = OrderInsertDTO(
            id: orderId,
            user_id: AppConstants.TEMP_USER_ID,
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

        return orderId
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
                        condition
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
            .eq("user_id", value: AppConstants.TEMP_USER_ID.uuidString)
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
                    condition
                )
            """)
            .eq("order_id", value: orderId.uuidString)
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
