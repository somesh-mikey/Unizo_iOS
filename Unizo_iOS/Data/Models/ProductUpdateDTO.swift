//
//  ProductUpdateDTO.swift
//  Unizo_iOS
//
//  Created by Soham Bhattacharya on 01/02/26.
//

import Foundation

struct ProductUpdateDTO: Encodable {
    let title: String
    let description: String
    let price: Int
    let image_url: String
    let is_negotiable: Bool
    let colour: String
    let category: String
    let size: String
    let condition: String
}
