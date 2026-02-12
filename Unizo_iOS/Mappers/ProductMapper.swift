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
            imageURL: dto.imageUrl,
            galleryImages: dto.galleryImages ?? [],
            category: dto.category,
            colour: dto.colour,
            size: dto.size,
            condition: dto.condition,
            sellerName: dto.sellerDisplayName,
            sellerId: dto.seller?.id,  // Preserve seller ID for notifications
            quantity: dto.quantity ?? 1,
            status: dto.status ?? .available
        )
    }
}






