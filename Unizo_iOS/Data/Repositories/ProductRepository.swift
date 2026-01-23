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
                quantity,
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
                quantity,
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
                quantity,
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
                quantity,
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
    // MARK: - Banners
    func fetchBanners() async throws -> [BannerDTO] {
        let response = try await supabase
            .from("banners")
            .select("id, image_url, position")
            .eq("is_active", value: true)
            .order("position", ascending: true)
            .execute()

        return try JSONDecoder().decode([BannerDTO].self, from: response.data)
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
                quantity,
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
    
    func insertProduct(_ product: ProductInsertDTO) async throws {
            try await supabase
                .from("products")
                .insert(product)
                .execute()
        }

    // MARK: - Increment View Count
    /// Increments the view_count for a product when it's viewed
    func incrementViewCount(productId: UUID) async throws {
        // Use lowercase UUID string for Supabase compatibility
        let productIdString = productId.uuidString.lowercased()

        // First fetch current view count
        let response = try await supabase
            .from("products")
            .select("views_count")
            .eq("id", value: productIdString)
            .single()
            .execute()

        struct ViewCountResponse: Decodable {
            let views_count: Int?
        }

        let current = try JSONDecoder().decode(ViewCountResponse.self, from: response.data)
        let currentCount = current.views_count ?? 0
        let newCount = currentCount + 1

        print("👁️ Product \(productIdString): current views = \(currentCount), incrementing to \(newCount)")

        // Update with incremented count
        struct ViewCountUpdate: Encodable {
            let views_count: Int
        }

        try await supabase
            .from("products")
            .update(ViewCountUpdate(views_count: newCount))
            .eq("id", value: productIdString)
            .execute()

        print("👁️ View count updated to \(newCount) for product \(productIdString)")
    }

    // MARK: - Decrement Product Quantity (after purchase)
    /// Decrements quantity and marks product as inactive if quantity becomes 0
    func decrementQuantity(productId: UUID, by amount: Int = 1) async throws {
        // Use lowercase UUID string for Supabase compatibility
        let productIdString = productId.uuidString.lowercased()

        // First fetch current quantity
        let response = try await supabase
            .from("products")
            .select("quantity")
            .eq("id", value: productIdString)
            .single()
            .execute()

        struct QuantityResponse: Decodable {
            let quantity: Int?
        }

        let current = try JSONDecoder().decode(QuantityResponse.self, from: response.data)
        let currentQty = current.quantity ?? 1
        let newQty = max(0, currentQty - amount)

        // Update quantity and set is_active to false if quantity is 0
        struct QuantityUpdate: Encodable {
            let quantity: Int
            let is_active: Bool
        }

        try await supabase
            .from("products")
            .update(QuantityUpdate(quantity: newQty, is_active: newQty > 0))
            .eq("id", value: productIdString)
            .execute()

        print("📦 Product \(productIdString) quantity updated to \(newQty), is_active: \(newQty > 0)")
    }
}
