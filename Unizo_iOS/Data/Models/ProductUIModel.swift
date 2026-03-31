//
//  ProductUIModel.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation
import FirebaseFirestore

struct ProductUIModel {
    @DocumentID var id: String?
    let name: String
    let description: String?
    let price: Double
    let rating: Double
    let negotiable: Bool
    let imageURL: String?
    let galleryImages: [String]  // Array of additional image URLs
    let category: String?
    let colour: String?
    let size: String?
    let condition: String?
    let sellerName: String
    let sellerId: String?  // Preserve seller ID for notifications

    // Inventory fields (var to allow mutation when product is sold via notification)
    var quantity: Int
    var status: ProductStatus

    // Computed property to check if product is available for purchase
    var isAvailable: Bool {
        return status == .available && quantity > 0
    }

    // All images (main + gallery) for carousel display
    var allImages: [String] {
        var images: [String] = []
        if let mainImage = imageURL, !mainImage.isEmpty {
            images.append(mainImage)
        }
        images.append(contentsOf: galleryImages)
        return images
    }
}




