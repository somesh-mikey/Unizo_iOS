//
//  OrderDTO.swift
//  Unizo_iOS
//
//  Created by Somesh on 22/01/26.
//

import Foundation
import FirebaseFirestore

// MARK: - Order Status
enum OrderStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case shipped = "shipped"
    case delivered = "delivered"
    case cancelled = "cancelled"
}

// MARK: - Order DTO (for fetching from Firestore)
struct OrderDTO: Codable {
    @DocumentID var id: String?
    let user_id: String
    let address_id: String
    let status: String
    let total_amount: Double
    let payment_method: String
    let instructions: String?
    let created_at: String
    let handoff_code: String?
    let handoff_code_generated_at: String?

    // Joined data (optional, for fetching with relations)
    var items: [OrderItemDTO]?
    var address: AddressDTO?
}

// MARK: - Order Item DTO
struct OrderItemDTO: Codable {
    @DocumentID var id: String?
    let order_id: String
    let product_id: String
    let quantity: Int
    let price_at_purchase: Double
    let colour: String?
    let size: String?

    // Joined product data (optional)
    var product: ProductDTO?
}

// MARK: - Insert DTOs (for creating new orders)
struct OrderInsertDTO: Encodable {
    @DocumentID var id: String?
    let user_id: String
    let address_id: String
    let status: String
    let total_amount: Double
    let payment_method: String
    let instructions: String?
    let created_at: String
}

struct OrderItemInsertDTO: Encodable {
    @DocumentID var id: String?
    let order_id: String
    let product_id: String
    let quantity: Int
    let price_at_purchase: Double
    let colour: String?
    let size: String?
}

// MARK: - Order UI Model (for display)
struct OrderUIModel {
    @DocumentID var id: String?
    let orderId: String
    let status: OrderStatus
    let totalAmount: Double
    let paymentMethod: String
    let instructions: String?
    let createdAt: Date
    let items: [OrderItemUIModel]
    let address: AddressDTO?
    let handoffCode: String?
}

struct OrderItemUIModel {
    @DocumentID var id: String?
    let productId: String
    let productName: String
    let productImage: String?
    let category: String?
    let quantity: Int
    let price: Double
    let colour: String?
    let size: String?
}
