//
//  BannerDTO.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/01/26.
//

import Foundation

struct BannerDTO: Decodable {
    let id: UUID
    let image_url: String
    let position: Int
}

