//
//  BannerDTO.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/01/26.
//

import Foundation
import FirebaseFirestore

struct BannerDTO: Decodable {
    @DocumentID var id: String?
    let image_url: String
    let position: Int
}

