//
//  ProductInsertDTO.swift
//  Unizo_iOS
//
//  Created by Nishtha on 13/01/26.
//

import Foundation
import FirebaseFirestore

struct ProductInsertDTO: Encodable {
    let seller_id: String
    let title: String
    let description: String
    let price: Int
    let image_url: String
    let gallery_images: [String]?  // Array of additional image URLs
    let is_negotiable: Bool
    let views_count: Int
    let is_active: Bool
    let rating: Double
    let colour: String
    let category: String
    let size: String
    let condition: String
    let status: String = "available"
    let quantity: Int = 1
    let created_at: String = ISO8601DateFormatter().string(from: Date())
}
