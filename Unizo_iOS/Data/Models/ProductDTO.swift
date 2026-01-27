//
//  Product.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation

// Nested seller info from users table
struct ProductSellerDTO: Codable {
    let id: UUID
    let first_name: String?
    let last_name: String?
}

struct ProductDTO: Codable {
    let id: UUID
    let title: String
    let description: String?
    let price: Double
    let rating: Double?
    let isNegotiable: Bool?
    let imageUrl: String?
    let viewsCount: Int?

    let colour: String?
    let category: String?
    let size: String?
    let condition: String?

    // Seller info (joined from users table)
    let seller: ProductSellerDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case price
        case rating
        case imageUrl = "image_url"
        case isNegotiable = "is_negotiable"
        case viewsCount = "views_count"
        case colour
        case category
        case size
        case condition
        case seller
    }

    // Computed property for seller display name
    var sellerDisplayName: String {
        guard let seller = seller else { return "Unknown Seller" }
        let firstName = seller.first_name ?? ""
        let lastName = seller.last_name ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return fullName.isEmpty ? "Unknown Seller" : fullName
    }
}
