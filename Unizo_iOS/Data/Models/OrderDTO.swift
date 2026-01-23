//
//  OrderDTO.swift
//  Unizo_iOS
//
//  Created by Somesh on 22/01/26.
//

import Foundation

// MARK: - Order Status
enum OrderStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case shipped = "shipped"
    case delivered = "delivered"
    case cancelled = "cancelled"
}

// MARK: - Order DTO (for fetching from Supabase)
struct OrderDTO: Codable {
    let id: UUID
    let user_id: UUID
    let address_id: UUID
    let status: String
    let total_amount: Double
    let payment_method: String
    let instructions: String?
    let created_at: String

    // Joined data (optional, for fetching with relations)
    var items: [OrderItemDTO]?
    var address: AddressDTO?
}

// MARK: - Order Item DTO
struct OrderItemDTO: Codable {
    let id: UUID
    let order_id: UUID
    let product_id: UUID
    let quantity: Int
    let price_at_purchase: Double
    let colour: String?
    let size: String?

    // Joined product data (optional)
    var product: ProductDTO?
}

// MARK: - Insert DTOs (for creating new orders)
struct OrderInsertDTO: Encodable {
    let id: UUID
    let user_id: UUID
    let address_id: UUID
    let status: String
    let total_amount: Double
    let payment_method: String
    let instructions: String?
}

struct OrderItemInsertDTO: Encodable {
    let id: UUID
    let order_id: UUID
    let product_id: UUID
    let quantity: Int
    let price_at_purchase: Double
    let colour: String?
    let size: String?
}

// MARK: - Order UI Model (for display)
struct OrderUIModel {
    let id: UUID
    let orderId: String
    let status: OrderStatus
    let totalAmount: Double
    let paymentMethod: String
    let instructions: String?
    let createdAt: Date
    let items: [OrderItemUIModel]
    let address: AddressDTO?
}

struct OrderItemUIModel {
    let id: UUID
    let productId: UUID
    let productName: String
    let productImage: String?
    let category: String?
    let quantity: Int
    let price: Double
    let colour: String?
    let size: String?
}
