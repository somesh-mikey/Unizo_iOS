//
//  ProductRepository.swift
//  Unizo_iOS
//
//  Data access layer for the `products` table. All fetch methods that
//  target the buyer feed auto-exclude the current user's own listings,
//  sold items, and zero-quantity stock. Seller-facing queries (e.g.
//  fetchSellerProducts) do not apply these filters.
//

import Foundation
import Supabase

final class ProductRepository {

    private let supabase: SupabaseClient
    private let pageSize = 20

    // Shared select field list. `gallery_images` is optional in ProductDTO
    // to handle older database schemas that predate that column.
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

    /// In-memory cache populated on page 1. Used for cart suggestions and
    /// category reuse across screens without a round-trip.
    private(set) var cachedProducts: [ProductDTO] = []

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    /// Removes a single product from the in-memory cache (call after deletion).
    func removeFromCache(productId: UUID) {
        cachedProducts.removeAll { $0.id == productId }
    }

    // MARK: - Helpers

    private func getCurrentUserId() async -> UUID? {
        await AuthManager.shared.currentUserId
    }

    private func requireNetwork() throws {
        guard NetworkMonitor.shared.isReachable() else {
            throw NetworkError.noConnection
        }
    }

    // MARK: - Fetch All (Paginated)

    func fetchAllProducts(page: Int) async throws -> [ProductDTO] {
        try requireNetwork()

        guard page >= 1 else {
            print("⚠️ Invalid page index:", page)
            return []
        }

        let from = (page - 1) * pageSize
        let to   = from + pageSize - 1

        let currentUserId = await getCurrentUserId()

        var query = supabase
            .from("products")
            .select(productSelectFields)
            .eq("is_active", value: true)
            .neq("status", value: "sold")
            .gt("quantity", value: 0)

        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query.range(from: from, to: to).execute()

        if let jsonString = String(data: response.data, encoding: .utf8) {
            print("🔍 Raw Supabase response (first 2000 chars):", String(jsonString.prefix(2000)))
        }

        var products = try JSONDecoder().decode([ProductDTO].self, from: response.data)

        // Apply local blocked-user filter for immediate effect while the
        // Row-Level Security policy propagates.
        let blockedUsers = BlockedUsersStore.all()
        if !blockedUsers.isEmpty {
            products = products.filter { product in
                guard let sellerId = product.seller?.id.uuidString else { return true }
                return !blockedUsers.contains(sellerId)
            }
        }

        // Filter out locally-deleted product IDs so they never reappear
        let deletedIds = DeletedListingsStore.all()
        if !deletedIds.isEmpty {
            products = products.filter { !deletedIds.contains($0.id.uuidString) }
        }

        print("📥 Supabase returned:", products.count)

        if let first = products.first {
            print("🔍 First product seller:", first.seller ?? "nil")
            print("🔍 First product sellerDisplayName:", first.sellerDisplayName)
        }

        if page == 1 && cachedProducts.isEmpty {
            cachedProducts = products
            print("📦 Cached products:", cachedProducts.count)
        }

        return products
    }

    // MARK: - Curated Feeds

    func fetchPopularProducts() async throws -> [ProductDTO] {
        try requireNetwork()
        let currentUserId = await getCurrentUserId()

        var query = supabase
            .from("products")
            .select(productSelectFields)
            .eq("is_active", value: true)
            .neq("status", value: "sold")
            .gt("quantity", value: 0)

        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query
            .order("views_count", ascending: false)
            .limit(pageSize)
            .execute()

        var dtos = try JSONDecoder().decode([ProductDTO].self, from: response.data)
        let deletedIds = DeletedListingsStore.all()
        if !deletedIds.isEmpty {
            dtos = dtos.filter { !deletedIds.contains($0.id.uuidString) }
        }
        return dtos
    }

    func fetchNegotiableProducts() async throws -> [ProductDTO] {
        try requireNetwork()
        let currentUserId = await getCurrentUserId()

        var query = supabase
            .from("products")
            .select(productSelectFields)
            .eq("is_active", value: true)
            .eq("is_negotiable", value: true)
            .neq("status", value: "sold")
            .gt("quantity", value: 0)

        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query.execute()
        var dtos = try JSONDecoder().decode([ProductDTO].self, from: response.data)
        let deletedIds = DeletedListingsStore.all()
        if !deletedIds.isEmpty {
            dtos = dtos.filter { !deletedIds.contains($0.id.uuidString) }
        }
        return dtos
    }

    func fetchProductsByCategory(_ category: String) async throws -> [ProductDTO] {
        try requireNetwork()
        let currentUserId = await getCurrentUserId()

        var query = supabase
            .from("products")
            .select(productSelectFields)
            .eq("category", value: category)
            .eq("is_active", value: true)
            .neq("status", value: "sold")
            .gt("quantity", value: 0)

        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query.execute()
        var dtos = try JSONDecoder().decode([ProductDTO].self, from: response.data)
        let deletedIds = DeletedListingsStore.all()
        if !deletedIds.isEmpty {
            dtos = dtos.filter { !deletedIds.contains($0.id.uuidString) }
        }
        return dtos
    }

    func fetchBanners() async throws -> [BannerDTO] {
        try requireNetwork()
        let response = try await supabase
            .from("banners")
            .select("id, image_url, position")
            .eq("is_active", value: true)
            .order("position", ascending: true)
            .execute()

        return try JSONDecoder().decode([BannerDTO].self, from: response.data)
    }

    // MARK: - Search

    func searchProducts(keyword: String) async throws -> [ProductDTO] {
        try requireNetwork()

        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let pattern       = "%\(trimmed)%"
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

        if let userId = currentUserId {
            query = query.neq("seller_id", value: userId.uuidString)
        }

        let response = try await query.execute()
        var dtos = try JSONDecoder().decode([ProductDTO].self, from: response.data)
        let deletedIds = DeletedListingsStore.all()
        if !deletedIds.isEmpty {
            dtos = dtos.filter { !deletedIds.contains($0.id.uuidString) }
        }
        return dtos
    }

    // MARK: - Write

    func insertProduct(_ product: ProductInsertDTO) async throws {
        try requireNetwork()
        try await supabase.from("products").insert(product).execute()
    }

    // MARK: - Inventory

    private struct ProductInventoryUpdate: Codable {
        let quantity: Int
        let status: String
    }

    /// Decrements quantity by `quantitySold` and marks the product as
    /// "sold" if the resulting quantity reaches zero.
    func markProductAsSold(productId: UUID, quantitySold: Int = 1) async throws {
        try requireNetwork()

        let response = try await supabase
            .from("products")
            .select("quantity")
            .eq("id", value: productId.uuidString)
            .single()
            .execute()

        struct QuantityResult: Codable { let quantity: Int }

        let result      = try JSONDecoder().decode(QuantityResult.self, from: response.data)
        let newQuantity = max(0, result.quantity - quantitySold)
        let newStatus: String = newQuantity == 0 ? "sold" : "available"

        try await supabase
            .from("products")
            .update(ProductInventoryUpdate(quantity: newQuantity, status: newStatus))
            .eq("id", value: productId.uuidString)
            .execute()

        print("📦 Product \(productId) → quantity=\(newQuantity), status=\(newStatus)")
    }

    // MARK: - Single-Item Fetches

    func fetchProduct(id: UUID) async throws -> ProductDTO? {
        let response = try await supabase
            .from("products")
            .select(productSelectFields)
            .eq("id", value: id.uuidString)
            .single()
            .execute()

        return try JSONDecoder().decode(ProductDTO.self, from: response.data)
    }

    /// Returns all listings for `sellerId`, including the seller's own.
    /// Used by ListingsViewController and SellerDashboard.
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

    /// Increments views_count by 1. Called when a buyer opens a product detail screen.
    func incrementViewCount(productId: UUID) async throws {
        let response = try await supabase
            .from("products")
            .select("views_count")
            .eq("id", value: productId.uuidString)
            .single()
            .execute()

        struct ViewsResult: Codable { let views_count: Int? }

        let result    = try JSONDecoder().decode(ViewsResult.self, from: response.data)
        let newViews  = (result.views_count ?? 0) + 1

        struct ViewsUpdate: Codable { let views_count: Int }

        try await supabase
            .from("products")
            .update(ViewsUpdate(views_count: newViews))
            .eq("id", value: productId.uuidString)
            .execute()

        print("👁️ Product \(productId) views: \(newViews)")
    }
}
