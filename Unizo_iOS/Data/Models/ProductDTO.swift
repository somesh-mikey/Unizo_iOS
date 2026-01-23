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
    let rating: Double?
    let isNegotiable: Bool?
    let imageUrl: String?
    let viewsCount: Int?
    let quantity: Int?

    let colour: String?
    let category: String?
    let size: String?
    let condition: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case price
        case rating
        case imageUrl = "image_url"
        case isNegotiable = "is_negotiable"
        case viewsCount = "views_count"
        case quantity
        case colour
        case category
        case size
        case condition
    }
}
