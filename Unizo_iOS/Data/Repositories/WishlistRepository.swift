//
//  WishlistRepository.swift
//  Unizo_iOS
//
//  Created by Somesh on 04/01/26.
//

import Foundation
import FirebaseFirestore

final class WishlistRepository {

    private let db = Firestore.firestore()

    init() {}

    /// Fetches the user's wishlist from their subcollection, then manually
    /// joins the Product details from the root products collection.
    func fetchWishlist(userId: String) async throws -> [ProductDTO] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("wishlist")
            .getDocuments()

        var products: [ProductDTO] = []

        // Concurrent fetch for product joins (NoSQL workaround)
        try await withThrowingTaskGroup(of: ProductDTO?.self) { group in
            for doc in snapshot.documents {
                let productId = doc.documentID
                group.addTask {
                    let productSnap = try await self.db.collection("products").document(productId).getDocument()
                    return try? productSnap.data(as: ProductDTO.self)
                }
            }

            for try await product in group {
                if let product = product {
                    products.append(product)
                }
            }
        }

        return products
    }
}

extension WishlistRepository {

    /// Adds a product to the user's wishlist subcollection natively via Document ID
    func add(productId: String, userId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("wishlist")
            .document(productId)
            .setData([
                "product_id": productId,
                "created_at": FieldValue.serverTimestamp()
            ])
    }

    /// Removes the product from the user's wishlist
    func remove(productId: String, userId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("wishlist")
            .document(productId)
            .delete()
    }
}
