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
                    is_active,
                    rating,
                    colour,
                    category
                )
            """)
            .eq("user_id", value: userId.uuidString)
            .execute()

        // ✅ Force decode from raw Data
        let data = response.data


        let rows = try JSONDecoder().decode([WishlistRowDTO].self, from: data)
        return rows.map { $0.products }
    }

}
extension WishlistRepository {

    func add(productId: UUID, userId: UUID) async throws {
        try await supabase
            .from("wishlists")
            .insert([
                "product_id": productId.uuidString,
                "user_id": userId.uuidString
            ])
            .execute()
    }

    func remove(productId: UUID, userId: UUID) async throws {
        try await supabase
            .from("wishlists")
            .delete()
            .eq("product_id", value: productId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
}

