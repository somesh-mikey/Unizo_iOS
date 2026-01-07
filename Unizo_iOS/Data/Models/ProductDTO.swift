//
//  Product.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation

struct ProductDTO: Codable {
    let id: UUID
    let title: String
    let description: String?
    let price: Double

    let imageUrl: String?
    let isNegotiable: Bool?
    let viewsCount: Int?
    let isActive: Bool?
    let rating: Double?

    let colour: String?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case price
        case imageUrl = "image_url"
        case isNegotiable = "is_negotiable"
        case viewsCount = "views_count"
        case isActive = "is_active"
        case rating
        case colour
        case category
    }
}





