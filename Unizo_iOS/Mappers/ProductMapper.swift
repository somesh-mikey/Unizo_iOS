//
//  ProductMapper.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation

struct ProductMapper {

    static func toUIModel(_ dto: ProductDTO) -> ProductUIModel {

        let imageURL = dto.imageUrl.map {
            SupabaseStorageService.shared.publicImageURL(path: $0)
        }

        return ProductUIModel(
            id: dto.id,
            name: dto.title,
            description: dto.description,
            price: dto.price,
            rating: dto.rating ?? 0.0,
            negotiable: dto.isNegotiable ?? false,   // ✅ FIX
            imageName: imageURL,
            category: dto.category,
            colour: dto.colour,
            size: dto.size,                          // ✅ NOW EXISTS
            condition: dto.condition                 // ✅ NOW EXISTS
        )
    }
}






