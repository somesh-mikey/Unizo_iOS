//
//  BannerDTO.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/01/26.
//

import Foundation
import FirebaseFirestore

struct BannerDTO: Codable, Identifiable {
    @DocumentID var id: String?
    let image_url: String
    let position: Int
    let is_active: Bool?
    let title: String?
    let link_url: String?
}
