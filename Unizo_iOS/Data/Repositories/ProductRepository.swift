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

    // Standard select fields for all product queries
    private let productSelectFields = """
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
        condition,
        quantity,
        status,
        seller_id,
        seller:users!seller_id(id, first_name, last_name, email)
    """

    // In-memory cache (used for cart suggestions, category reuse, etc.)
    private(set) var cachedProducts: [ProductDTO] = []

    // MARK: - Init
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    // MARK: - Helper: Get current user ID
    private func getCurrentUserId() async -> UUID? {
        return await AuthManager.shared.currentUserId
    }

    // MARK: - Fetch All Products (Paginated)
    /// Fetches products excluding:
    /// - Sold products (status = 'sold')
    /// - Products with quantity = 0
    /// - Current user's own products (sellers shouldn't see their own listings in buyer views)
    func fetchAllProducts(page: Int) async throws -> [ProductDTO] {

        guard page >= 1 else {
            print("⚠️ Invalid page index:", page)
            return []
        }

        let from = (page - 1) * pageSize
        let to = from + pageSize - 1

        // Get current user ID to exclude their products
        let currentUserId = await getCurrentUserId()

        var query = supabase
            .from("products")
            .select(productSelectFields)
            .eq("is_active", value: true)
            .neq("status", value: "sold")  // Exclude sold products
            .gt("quantity", value: 0)       // Exclude zero-quantity products

        // Exclude current user's own products if logged in
        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query
            .range(from: from, to: to)
            .execute()

        // Debug: Print raw JSON to see what Supabase returns
        if let jsonString = String(data: response.data, encoding: .utf8) {
            print("🔍 Raw Supabase response (first 2000 chars):", String(jsonString.prefix(2000)))
        }

        let products = try JSONDecoder().decode([ProductDTO].self, from: response.data)

        print("📥 Supabase returned:", products.count)

        // Debug: Check seller info for first product
        if let first = products.first {
            print("🔍 First product seller:", first.seller ?? "nil")
            print("🔍 First product sellerDisplayName:", first.sellerDisplayName)
        }

        // Cache only once
        if page == 1 && cachedProducts.isEmpty {
            cachedProducts = products
            print("📦 Cached products:", cachedProducts.count)
        }

        return products
    }

    // MARK: - Popular Products
    func fetchPopularProducts() async throws -> [ProductDTO] {

        // Get current user ID to exclude their products
        let currentUserId = await getCurrentUserId()

        var query = supabase
            .from("products")
            .select(productSelectFields)
            .eq("is_active", value: true)
            .neq("status", value: "sold")
            .gt("quantity", value: 0)

        // Exclude current user's own products if logged in
        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query
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

        // Get current user ID to exclude their products
        let currentUserId = await getCurrentUserId()

        var query = supabase
            .from("products")
            .select(productSelectFields)
            .eq("is_active", value: true)
            .eq("is_negotiable", value: true)
            .neq("status", value: "sold")
            .gt("quantity", value: 0)

        // Exclude current user's own products if logged in
        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query.execute()

        return try JSONDecoder().decode(
            [ProductDTO].self,
            from: response.data
        )
    }

    // MARK: - Products by Category
    func fetchProductsByCategory(_ category: String) async throws -> [ProductDTO] {

        // Get current user ID to exclude their products
        let currentUserId = await getCurrentUserId()

        var query = supabase
            .from("products")
            .select(productSelectFields)
            .eq("category", value: category)
            .eq("is_active", value: true)
            .neq("status", value: "sold")
            .gt("quantity", value: 0)

        // Exclude current user's own products if logged in
        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query.execute()

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

        // Get current user ID to exclude their products
        let currentUserId = await getCurrentUserId()

        var query = supabase
            .from("products")
            .select(productSelectFields)
            .eq("is_active", value: true)
            .neq("status", value: "sold")
            .gt("quantity", value: 0)
            .or(
                "title.ilike.\(pattern)," +
                "description.ilike.\(pattern)," +
                "category.ilike.\(pattern)"
            )

        // Exclude current user's own products if logged in
        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query.execute()

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

    // MARK: - Update Product Status (for sold items)

    /// Struct for updating product inventory
    private struct ProductInventoryUpdate: Codable {
        let quantity: Int
        let status: String
    }

    /// Marks a product as sold and reduces quantity
    /// - Parameters:
    ///   - productId: The product UUID
    ///   - quantitySold: Number of items sold (default 1)
    func markProductAsSold(productId: UUID, quantitySold: Int = 1) async throws {
        // First fetch current quantity
        let response = try await supabase
            .from("products")
            .select("quantity")
            .eq("id", value: productId.uuidString)
            .single()
            .execute()

        struct QuantityResult: Codable {
            let quantity: Int
        }

        let result = try JSONDecoder().decode(QuantityResult.self, from: response.data)
        let newQuantity = max(0, result.quantity - quantitySold)
        let newStatus: String = newQuantity == 0 ? "sold" : "available"

        // Update product with Encodable struct
        let updateData = ProductInventoryUpdate(quantity: newQuantity, status: newStatus)

        try await supabase
            .from("products")
            .update(updateData)
            .eq("id", value: productId.uuidString)
            .execute()

        print("📦 Product \(productId) updated: quantity=\(newQuantity), status=\(newStatus)")
    }

    /// Fetches a single product by ID (used for detail views)
    func fetchProduct(id: UUID) async throws -> ProductDTO? {
        let response = try await supabase
            .from("products")
            .select(productSelectFields)
            .eq("id", value: id.uuidString)
            .single()
            .execute()

        return try JSONDecoder().decode(ProductDTO.self, from: response.data)
    }

    /// Fetches products for a specific seller (for ListingsViewController)
    /// This does NOT exclude seller's own products (since that's the whole point)
    func fetchSellerProducts(sellerId: UUID) async throws -> [ProductDTO] {
        let response = try await supabase
            .from("products")
            .select(productSelectFields)
            .eq("seller_id", value: sellerId.uuidString)
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()

        return try JSONDecoder().decode([ProductDTO].self, from: response.data)
    }
}
