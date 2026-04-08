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
        print("🔍 WishlistRepository.fetchWishlist: userId = \(userId)")

        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("wishlist")
            .getDocuments()

        print("📋 Wishlist subcollection has \(snapshot.documents.count) entries")

        var products: [ProductDTO] = []

        // Concurrent fetch for product joins (NoSQL workaround)
        try await withThrowingTaskGroup(of: ProductDTO?.self) { group in
            for doc in snapshot.documents {
                let productId = doc.documentID
                print("🔍 Fetching wishlist product: \(productId)")

                group.addTask {
                    do {
                        let productSnap = try await self.db.collection("products")
                            .document(productId)
                            .getDocument()

                        guard productSnap.exists else {
                            print("⚠️ Product \(productId) no longer exists in Firestore")
                            return nil
                        }

                        // Try Codable decode first
                        do {
                            var product = try productSnap.data(as: ProductDTO.self)
                            if product.id == nil {
                                product.id = productSnap.documentID
                            }
                            return product
                        } catch {
                            print("⚠️ Codable decode failed for \(productId): \(error) — trying manual decode")
                        }

                        // Fallback: manual decode for missing fields
                        guard let data = productSnap.data(),
                              let title = data["title"] as? String else {
                            print("❌ Cannot decode product \(productId): missing title field")
                            return nil
                        }

                        // Return a minimal ProductDTO if Codable decode fails
                        // This prevents one malformed product from breaking the whole wishlist
                        var dto = ProductDTO(
                            title: title,
                            description: data["description"] as? String,
                            price: data["price"] as? Double ?? 0,
                            rating: data["rating"] as? Double,
                            isNegotiable: data["is_negotiable"] as? Bool,
                            imageUrl: data["image_url"] as? String,
                            galleryImages: data["gallery_images"] as? [String],
                            viewsCount: data["views_count"] as? Int,
                            colour: data["colour"] as? String,
                            category: data["category"] as? String,
                            size: data["size"] as? String,
                            condition: data["condition"] as? String,
                            is_active: data["is_active"] as? Bool,
                            quantity: data["quantity"] as? Int,
                            status: ProductStatus(rawValue: data["status"] as? String ?? "available"),
                            seller_id: data["seller_id"] as? String,
                            seller: nil
                        )
                        dto.id = productSnap.documentID
                        return dto

                    } catch {
                        print("❌ Failed to fetch product \(productId): \(error)")
                        return nil
                    }
                }
            }

            for try await product in group {
                if let product = product {
                    products.append(product)
                }
            }
        }

        let blockedUsers = BlockedUsersStore.all()
        if !blockedUsers.isEmpty {
            let beforeCount = products.count
            products = products.filter { product in
                guard let sellerId = product.seller_id else { return true }
                return !blockedUsers.contains(sellerId)
            }

            let removedCount = beforeCount - products.count
            if removedCount > 0 {
                print("🚫 [Moderation] WishlistRepository.fetchWishlist filtered \(removedCount) blocked-seller products")
            }
        }

        let enrichedProducts = await ProductRepository().applySellerAverageRatings(to: products)

        print("✅ WishlistRepository: returning \(enrichedProducts.count) products")
        return enrichedProducts
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

    /// Returns true if the product exists in the user's wishlist subcollection.
    func contains(productId: String, userId: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("wishlist")
            .document(productId)
            .getDocument()
        return snapshot.exists
    }
}
