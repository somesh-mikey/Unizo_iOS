//
//  WishlistRepository.swift
//  Unizo_iOS
//
//  Created by Somesh on 04/01/26.
//

import Foundation
import Supabase

final class WishlistRepository {

    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    func fetchWishlist(userId: UUID) async throws -> [ProductDTO] {
        let userIdStr = userId.uuidString.lowercased()

        let response = try await supabase
            .from("wishlists")
            .select("""
                products!wishlists_product_id_fkey (
                    id,
                    title,
                    description,
                    price,
                    image_url,
                    is_negotiable,
                    views_count,
                    quantity,
                    is_active,
                    rating,
                    colour,
                    category,
                    size,
                    condition
                )
            """)
            .eq("user_id", value: userIdStr)
            .execute()

        // ✅ Force decode from raw Data
        let data = response.data

        let rows = try JSONDecoder().decode([WishlistRowDTO].self, from: data)
        print("❤️ Fetched \(rows.count) wishlist items for user \(userIdStr)")
        return rows.map { $0.products }
    }

}
extension WishlistRepository {

    func add(productId: UUID, userId: UUID) async throws {
        let productIdStr = productId.uuidString.lowercased()
        let userIdStr = userId.uuidString.lowercased()

        try await supabase
            .from("wishlists")
            .insert([
                "product_id": productIdStr,
                "user_id": userIdStr
            ])
            .execute()

        print("❤️ Added to wishlist: product \(productIdStr) for user \(userIdStr)")
    }

    func remove(productId: UUID, userId: UUID) async throws {
        let productIdStr = productId.uuidString.lowercased()
        let userIdStr = userId.uuidString.lowercased()

        try await supabase
            .from("wishlists")
            .delete()
            .eq("product_id", value: productIdStr)
            .eq("user_id", value: userIdStr)
            .execute()

        print("💔 Removed from wishlist: product \(productIdStr) for user \(userIdStr)")
    }
}

