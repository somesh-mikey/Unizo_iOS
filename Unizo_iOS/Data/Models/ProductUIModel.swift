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
    let imageURL: String?   // ✅ MUST BE OPTIONAL
    let category: String?
    let colour: String?
    let size: String?
    let condition: String?
}




