//
//  OrderRatingDTO.swift
//  Unizo_iOS
//

import Foundation
import FirebaseFirestore

// MARK: - Order Rating DTO
struct OrderRatingDTO: Codable {
    @DocumentID var id: String?
    let order_id: String
    let rater_id: String  // User who is rating (buyer or seller)
    let rated_user_id: String  // User being rated
    let rating: Int  // 1-5 stars
    let review: String?  // Optional written review
    let created_at: String
    
    enum CodingKeys: String, CodingKey {
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
    let order_id: String
    let rater_id: String
    let rated_user_id: String
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
