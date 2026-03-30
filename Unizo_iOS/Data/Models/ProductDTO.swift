//
//  Product.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation

// MARK: - Product Status Enum
enum ProductStatus: String, Codable {
    case available = "available"
    case pending = "pending"
    case sold = "sold"
}

// Nested seller info from users table
struct ProductSellerDTO: Codable {
    let id: UUID
    let first_name: String?
    let last_name: String?
    let email: String?
}

struct ProductDTO: Codable {
    let id: UUID
    let title: String
    let description: String?
    let price: Double
    let rating: Double?
    let isNegotiable: Bool?
    let imageUrl: String?
    let galleryImages: [String]?  // Array of additional image URLs
    let viewsCount: Int?

    let colour: String?
    let category: String?
    let size: String?
    let condition: String?

    // Inventory fields
    let quantity: Int?
    let status: ProductStatus?

    // Seller info (joined from users table)
    let seller: ProductSellerDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case price
        case rating
        case imageUrl = "image_url"
        case galleryImages = "gallery_images"
        case isNegotiable = "is_negotiable"
        case viewsCount = "views_count"
        case colour
        case category
        case size
        case condition
        case quantity
        case status
        case seller
    }

    // Computed property for seller display name
    var sellerDisplayName: String {
        guard let seller = seller else { return "Unknown Seller" }
        let firstName = seller.first_name ?? ""
        let lastName = seller.last_name ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)

        // Use full name if available, otherwise use email prefix, otherwise "Unknown Seller"
        if !fullName.isEmpty {
            return fullName
        } else if let email = seller.email, !email.isEmpty {
            // Use part before @ as display name
            return email.components(separatedBy: "@").first ?? "Unknown Seller"
        } else {
            return "Unknown Seller"
        }
    }
}
