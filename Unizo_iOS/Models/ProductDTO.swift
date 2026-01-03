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
    let images: [String]
    let isNegotiable: Bool
    let viewsCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case price
        case images
        case isNegotiable = "is_negotiable"
        case viewsCount = "views_count"
    }
}


