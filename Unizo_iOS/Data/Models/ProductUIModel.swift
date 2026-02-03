//
//  ProductUIModel.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation

struct ProductUIModel {
    let id: UUID
    let name: String
    let description: String?
    let price: Double
    let rating: Double
    let negotiable: Bool
    let imageURL: String?
    let category: String?
    let colour: String?
    let size: String?
    let condition: String?
    let sellerName: String
    let sellerId: UUID?  // Preserve seller ID for notifications

    // Inventory fields
    let quantity: Int
    let status: ProductStatus

    // Computed property to check if product is available for purchase
    var isAvailable: Bool {
        return status == .available && quantity > 0
    }
}




