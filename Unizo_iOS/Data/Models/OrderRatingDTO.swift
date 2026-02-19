//
//  OrderRatingDTO.swift
//  Unizo_iOS
//

import Foundation

// MARK: - Order Rating DTO
struct OrderRatingDTO: Codable {
    let id: UUID
    let order_id: UUID
    let rater_id: UUID  // User who is rating (buyer or seller)
    let rated_user_id: UUID  // User being rated
    let rating: Int  // 1-5 stars
    let review: String?  // Optional written review
    let created_at: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case order_id
        case rater_id
        case rated_user_id
        case rating
        case review
        case created_at
    }
}

// MARK: - Order Rating Insert DTO (for creating)
struct OrderRatingInsertDTO: Encodable {
    let order_id: UUID
    let rater_id: UUID
    let rated_user_id: UUID
    let rating: Int
    let review: String?
    
    enum CodingKeys: String, CodingKey {
        case order_id
        case rater_id
        case rated_user_id
        case rating
        case review
    }
}
