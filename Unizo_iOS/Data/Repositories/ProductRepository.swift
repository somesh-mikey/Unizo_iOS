//
//  ProductRepository.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation
import Supabase

final class ProductRepository {

    // MARK: - Properties
    private let supabase: SupabaseClient
    private let pageSize = 20

    // In-memory cache (used for cart suggestions, category reuse, etc.)
    private(set) var cachedProducts: [ProductDTO] = []

    // MARK: - Init
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    // MARK: - Fetch All Products (Paginated)
    func fetchAllProducts(page: Int) async throws -> [ProductDTO] {

        guard page >= 1 else {
                print("⚠️ Invalid page index:", page)
                return []
            }

        let from = (page - 1) * pageSize
        let to = from + pageSize - 1

        let response = try await supabase
            .from("products")
            .select("""
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
                category,
                size,
                condition
            """)
            .eq("is_active", value: true)
            .range(from: from, to: to)
            .execute()

        let products = try JSONDecoder().decode([ProductDTO].self, from: response.data)

        print("📥 Supabase returned:", products.count)

        // Cache only once
        if page == 1 && cachedProducts.isEmpty {
            cachedProducts = products
            print("📦 Cached products:", cachedProducts.count)
        }

        return products
    }

    // MARK: - Popular Products
    func fetchPopularProducts() async throws -> [ProductDTO] {

        let response = try await supabase
            .from("products")
            .select("""
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
                category,
                size,
                condition
            """)
            .eq("is_active", value: true)
            .order("views_count", ascending: false)
            .limit(pageSize)
            .execute()

        return try JSONDecoder().decode(
            [ProductDTO].self,
            from: response.data
        )
    }

    // MARK: - Negotiable Products
    func fetchNegotiableProducts() async throws -> [ProductDTO] {

        let response = try await supabase
            .from("products")
            .select("""
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
                category,
                size,
                condition
            """)
            .eq("is_active", value: true)
            .eq("is_negotiable", value: true)
            .execute()

        return try JSONDecoder().decode(
            [ProductDTO].self,
            from: response.data
        )
    }

    // MARK: - Products by Category
    func fetchProductsByCategory(_ category: String) async throws -> [ProductDTO] {

        let response = try await supabase
            .from("products")
            .select("""
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
                category,
                size,
                condition
            """)
            .eq("category", value: category)
            .eq("is_active", value: true)
            .execute()

        return try JSONDecoder().decode(
            [ProductDTO].self,
            from: response.data
        )
    }

    // MARK: - Search Products
    func searchProducts(keyword: String) async throws -> [ProductDTO] {

        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let pattern = "%\(trimmed)%"

        let response = try await supabase
            .from("products")
            .select("""
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
                category,
                size,
                condition
            """)
            .eq("is_active", value: true)
            .or(
                "title.ilike.\(pattern)," +
                "description.ilike.\(pattern)," +
                "category.ilike.\(pattern)"
            )
            .execute()

        return try JSONDecoder().decode(
            [ProductDTO].self,
            from: response.data
        )
    }
}
