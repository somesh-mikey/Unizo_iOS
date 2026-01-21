//
//  ProductMapper.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation

struct ProductMapper {

    static func toUIModel(_ dto: ProductDTO) -> ProductUIModel {

        return ProductUIModel(
            id: dto.id,
            name: dto.title,
            description: dto.description,
            price: dto.price,
            rating: dto.rating ?? 0.0,
            negotiable: dto.isNegotiable ?? false,
            imageURL: dto.imageUrl,   // ✅ USE AS-IS
            category: dto.category,
            colour: dto.colour,
            size: dto.size,
            condition: dto.condition
        )
    }
}






