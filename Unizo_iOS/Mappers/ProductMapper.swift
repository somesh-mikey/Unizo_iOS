//
//  ProductMapper.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation

struct ProductMapper {
    static func map(_ dto: ProductDTO) -> ProductUIModel {
        ProductUIModel(
            id: dto.id,
            name: dto.title,
            price: dto.price,
            rating: 4.5, // temp / computed later
            negotiable: dto.isNegotiable,
            imageName: dto.images.first ?? "placeholder"
        )
    }
}


