//
//  ProductRepository.swift
//  Unizo_iOS
//
//  Data access layer for the `products` collection in Firestore. 
//  All fetch methods that target the buyer feed auto-exclude the current user's 
//  own listings, sold items, and zero-quantity stock using client-side 
//  filtering due to NoSQL inequality limitations.
//

import Foundation
import FirebaseFirestore

final class ProductRepository {

    private let db = Firestore.firestore()
    private let pageSize = 20
    private let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    private let iso8601WithoutFractionalSeconds = ISO8601DateFormatter()

    /// In-memory cache populated on page 1. Used for cart suggestions and
    /// category reuse across screens without a round-trip.
    private(set) var cachedProducts: [ProductDTO] = []
    
    /// Pagination cursor
    private var lastDocument: DocumentSnapshot?

    init() {}

    /// Removes a single product from the in-memory cache (call after deletion).
    func removeFromCache(productId: String) {
        cachedProducts.removeAll { $0.id == productId }
    }

    // MARK: - Helpers

    private func getCurrentUserId() async -> String? {
        await AuthManager.shared.currentUserId
    }

    private func requireNetwork() throws {
        guard NetworkMonitor.shared.isReachable() else {
            throw NetworkError.noConnection
        }
    }

    private func decodeProduct(from document: DocumentSnapshot) -> ProductDTO? {
        guard var product = try? document.data(as: ProductDTO.self) else {
            return nil
        }

        if product.id == nil {
            product.id = document.documentID
        }

        return product
    }

    private func decodeProducts(from documents: [QueryDocumentSnapshot]) -> [ProductDTO] {
        documents.compactMap { decodeProduct(from: $0) }
    }

    /// Helper to attach UserDTO seller profiles to each ProductDTO manually,
    /// mimicking the behavior of Supabase relational joins.
    private func attachSellers(to products: inout [ProductDTO]) async throws {
        let uniqueSellerIds = Array(Set(products.compactMap { $0.seller_id }))
        guard !uniqueSellerIds.isEmpty else { return }
        
        // Fetch all sellers in one go (chunked by 10 to respect Firestore 'in' limits if needed, 
        // but since pageSize is 20, max possible is 20).
        let sellerChunks = uniqueSellerIds.chunked(into: 10)
        var usersMap: [String: UserDTO] = [:]
        
        for chunk in sellerChunks {
            let snapshot = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            
            for doc in snapshot.documents {
                if let user = try? doc.data(as: UserDTO.self) {
                    usersMap[doc.documentID] = user
                }
            }
        }
        
        // Map sellers back to their products
        for index in products.indices {
            if let seller_id = products[index].seller_id, let user = usersMap[seller_id] {
                products[index].seller = ProductSellerDTO(id: user.id, first_name: user.first_name, last_name: user.last_name, email: user.email)
            }
        }
    }

    // MARK: - Fetch All (Paginated)

    func fetchAllProducts(page: Int) async throws -> [ProductDTO] {
        try requireNetwork()

        guard page >= 1 else {
            print("⚠️ Invalid page index:", page)
            return []
        }

        let currentUserId = await getCurrentUserId()

        var query = db.collection("products")
            .whereField("is_active", isEqualTo: true)
            .order(by: "created_at", descending: true)
            .limit(to: pageSize * 3)

        var fallbackQuery = db.collection("products")
            .limit(to: pageSize * 3)

        if page > 1, let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
            fallbackQuery = fallbackQuery.start(afterDocument: lastDoc)
        } else {
            lastDocument = nil // reset cursor
        }

        var snapshot: QuerySnapshot
        do {
            snapshot = try await query.getDocuments()
        } catch {
            print("⚠️ fetchAllProducts primary query failed, using fallback: \(error.localizedDescription)")
            snapshot = try await fallbackQuery.getDocuments()
        }

        if snapshot.documents.isEmpty {
            snapshot = try await fallbackQuery.getDocuments()
        }

        guard !snapshot.documents.isEmpty else { return [] }
        
        lastDocument = snapshot.documents.last
        
        var products = decodeProducts(from: snapshot.documents)

        // 1. Memory Filter: Active + Quantity + Status
        products = products.filter { ($0.is_active ?? true) && ($0.quantity ?? 1) > 0 && $0.status != .sold }

        // 2. Memory Filter: Remove current user's listings
        if let userId = currentUserId {
            products = products.filter { $0.seller_id != userId }
        }

        // Apply local blocked-user filter
        let blockedUsers = BlockedUsersStore.all()
        if !blockedUsers.isEmpty {
            products = products.filter { product in
                guard let seller_id = product.seller_id else { return true }
                return !blockedUsers.contains(seller_id)
            }
        }

        // Filter out locally-deleted product IDs
        let deletedIds = DeletedListingsStore.all()
        if !deletedIds.isEmpty {
            products = products.filter { product in
                guard let id = product.id else { return false }
                return !deletedIds.contains(id)
            }
        }

        products = Array(products.prefix(pageSize))
        try await attachSellers(to: &products)

        print("📥 Firestore returned:", products.count)

        if page == 1 {
            cachedProducts = products
            print("📦 Cached products:", cachedProducts.count)
        }

        return products
    }

    // MARK: - Curated Feeds

    func fetchPopularProducts() async throws -> [ProductDTO] {
        try requireNetwork()
        let currentUserId = await getCurrentUserId()

        let query = db.collection("products")
            .whereField("is_active", isEqualTo: true)
            .order(by: "views_count", descending: true)
            .limit(to: pageSize * 2)

        let fallbackQuery = db.collection("products").limit(to: pageSize * 3)

        var snapshot: QuerySnapshot
        do {
            snapshot = try await query.getDocuments()
        } catch {
            print("⚠️ fetchPopularProducts primary query failed, using fallback: \(error.localizedDescription)")
            snapshot = try await fallbackQuery.getDocuments()
        }

        if snapshot.documents.isEmpty {
            snapshot = try await fallbackQuery.getDocuments()
        }

        var products = decodeProducts(from: snapshot.documents)

        products = products.filter { ($0.is_active ?? true) && ($0.quantity ?? 1) > 0 && $0.status != .sold }
        if let userId = currentUserId { products = products.filter { $0.seller_id != userId } }

        products.sort { ($0.viewsCount ?? 0) > ($1.viewsCount ?? 0) }

        let deletedIds = DeletedListingsStore.all()
        if !deletedIds.isEmpty {
            products = products.filter { p in guard let id = p.id else { return false }; return !deletedIds.contains(id) }
        }

        products = Array(products.prefix(pageSize))
        try await attachSellers(to: &products)
        return products
    }

    func fetchNegotiableProducts() async throws -> [ProductDTO] {
        try requireNetwork()
        let currentUserId = await getCurrentUserId()

        let query = db.collection("products")
            .whereField("is_active", isEqualTo: true)
            .whereField("is_negotiable", isEqualTo: true)
            .order(by: "created_at", descending: true)
            .limit(to: pageSize * 2)

        let fallbackQuery = db.collection("products").limit(to: pageSize * 3)

        var snapshot: QuerySnapshot
        do {
            snapshot = try await query.getDocuments()
        } catch {
            print("⚠️ fetchNegotiableProducts primary query failed, using fallback: \(error.localizedDescription)")
            snapshot = try await fallbackQuery.getDocuments()
        }

        if snapshot.documents.isEmpty {
            snapshot = try await fallbackQuery.getDocuments()
        }

        var products = decodeProducts(from: snapshot.documents)

        products = products.filter {
            ($0.is_active ?? true) &&
            ($0.isNegotiable ?? false) &&
            ($0.quantity ?? 1) > 0 &&
            $0.status != .sold
        }
        if let userId = currentUserId { products = products.filter { $0.seller_id != userId } }

        products = Array(products.prefix(pageSize))
        try await attachSellers(to: &products)
        return products
    }

    func fetchProductsByCategory(_ category: String) async throws -> [ProductDTO] {
        try requireNetwork()
        let currentUserId = await getCurrentUserId()

        let query = db.collection("products")
            .whereField("category", isEqualTo: category)
            .whereField("is_active", isEqualTo: true)
            .order(by: "created_at", descending: true)
            .limit(to: pageSize * 2)

        let fallbackQuery = db.collection("products").limit(to: pageSize * 3)

        var snapshot: QuerySnapshot
        do {
            snapshot = try await query.getDocuments()
        } catch {
            print("⚠️ fetchProductsByCategory primary query failed, using fallback: \(error.localizedDescription)")
            snapshot = try await fallbackQuery.getDocuments()
        }

        if snapshot.documents.isEmpty {
            snapshot = try await fallbackQuery.getDocuments()
        }

        var products = decodeProducts(from: snapshot.documents)

        products = products.filter {
            ($0.is_active ?? true) &&
            (($0.category ?? "").caseInsensitiveCompare(category) == .orderedSame) &&
            ($0.quantity ?? 1) > 0 &&
            $0.status != .sold
        }
        if let userId = currentUserId { products = products.filter { $0.seller_id != userId } }

        products = Array(products.prefix(pageSize))
        try await attachSellers(to: &products)
        return products
    }

    func fetchBanners() async throws -> [BannerDTO] {
        try requireNetwork()
        do {
            let response = try await db.collection("banners")
                .whereField("is_active", isEqualTo: true)
                .order(by: "position", descending: false)
                .getDocuments()

            let decoded = response.documents.compactMap { try? $0.data(as: BannerDTO.self) }
            if !decoded.isEmpty {
                return decoded
            } else {
                // Seed the backend immediately with the CAD 4.0 poster natively mimicking the database presence
                print("⚠️ Banners collection is empty! Seeding CAD 4.0 poster to Firebase Backend directly...")
                for pos in 1...3 {
                    try? await db.collection("banners").addDocument(data: [
                        "image_url": "cad4_banner",
                        "position": pos,
                        "is_active": true
                    ])
                }
                
                // Fetch the newly planted remote documents so the layout draws organically from the DB return state
                let newResponse = try await db.collection("banners")
                    .whereField("is_active", isEqualTo: true)
                    .order(by: "position", descending: false)
                    .getDocuments()
                return newResponse.documents.compactMap { try? $0.data(as: BannerDTO.self) }
            }
        } catch {
            print("⚠️ fetchBanners primary query failed, using fallback: \(error.localizedDescription)")
        }

        let fallback = try await db.collection("banners").getDocuments()
        return fallback.documents
            .compactMap { try? $0.data(as: BannerDTO.self) }
            .sorted { $0.position < $1.position }
    }

    // MARK: - Search
    
    /// Searching relies strictly on a prefix/exact match query on the `category` 
    /// per NoSQL limitations, rather than an expensive ILIKE query across all fields.
    func searchProducts(keyword: String) async throws -> [ProductDTO] {
        try requireNetwork()

        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        // Exact category search fallback mapping
        let queryCategory = trimmed.capitalized

        let currentUserId = await getCurrentUserId()

        let query = db.collection("products")
            .whereField("category", isEqualTo: queryCategory)
            .whereField("is_active", isEqualTo: true)
            .limit(to: pageSize * 2)

        let snapshot = try await query.getDocuments()
        var products = decodeProducts(from: snapshot.documents)
        
        products = products.filter { $0.quantity ?? 0 > 0 && $0.status != .sold }
        if let userId = currentUserId { products = products.filter { $0.seller_id != userId } }

        let deletedIds = DeletedListingsStore.all()
        if !deletedIds.isEmpty {
            products = products.filter { p in guard let id = p.id else { return false }; return !deletedIds.contains(id) }
        }

        products = Array(products.prefix(pageSize))
        try await attachSellers(to: &products)
        return products
    }

    // MARK: - Write

    func insertProduct(_ product: ProductInsertDTO) async throws {
        try requireNetwork()
        let data = try Firestore.Encoder().encode(product)
        try await db.collection("products").addDocument(data: data)
    }

    func updateProduct(productId: String, update: ProductUpdateDTO) async throws {
        try requireNetwork()
        let data = try Firestore.Encoder().encode(update)
        try await db.collection("products").document(productId).updateData(data)
    }

    func softDeleteProduct(productId: String) async throws {
        try requireNetwork()
        try await db.collection("products").document(productId).updateData([
            "is_active": false
        ])
    }

    func deleteProduct(productId: String) async throws {
        try requireNetwork()
        try await db.collection("products").document(productId).delete()
    }

    // MARK: - Inventory

    /// Decrements quantity by `quantitySold` and marks the product as
    /// "sold" if the resulting quantity reaches zero.
    func markProductAsSold(productId: String, quantitySold: Int = 1) async throws {
        try requireNetwork()

        let ref = db.collection("products").document(productId)
        
        // Run a Firestore transaction to ensure we atomically read & update quantity
        _ = try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(ref)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let oldQuantity = document.data()?["quantity"] as? Int ?? 1
            
            let newQuantity = max(0, oldQuantity - quantitySold)
            let newStatus: String = newQuantity == 0 ? "sold" : "available"
            
            transaction.updateData([
                "quantity": newQuantity,
                "status": newStatus
            ], forDocument: ref)
            
            return nil
        })

        print("📦 Product \(productId) marked as sold/decremented")
    }

    // MARK: - Single-Item Fetches

    func fetchProduct(id: String) async throws -> ProductDTO? {
        let snapshot = try await db.collection("products").document(id).getDocument()
        guard snapshot.exists, var product = decodeProduct(from: snapshot) else {
            return nil
        }
        
        // Populate seller
        if let seller_id = product.seller_id {
            let sellerDoc = try await db.collection("users").document(seller_id).getDocument()
            if let u = try? sellerDoc.data(as: UserDTO.self) { product.seller = ProductSellerDTO(id: u.id, first_name: u.first_name, last_name: u.last_name, email: u.email) }
        }
        
        return product
    }

    /// Returns all listings for `seller_id`, including the seller's own.
    func fetchSellerProducts(seller_id: String) async throws -> [ProductDTO] {
        let indexedQuery = db.collection("products")
            .whereField("seller_id", isEqualTo: seller_id)
            .whereField("is_active", isEqualTo: true)
            .order(by: "created_at", descending: true)

        let documents: [QueryDocumentSnapshot]
        do {
            let snapshot = try await indexedQuery.getDocuments()
            documents = snapshot.documents
        } catch {
            print("⚠️ fetchSellerProducts(seller_id:) indexed query failed, using fallback: \(error.localizedDescription)")

            // Fallback avoids composite index requirements and sorts client-side.
            let fallbackSnapshot = try await db.collection("products")
                .whereField("seller_id", isEqualTo: seller_id)
                .getDocuments()

            documents = fallbackSnapshot.documents
                .filter { ($0.data()["is_active"] as? Bool) ?? true }
                .sorted { createdAtDate(for: $0) > createdAtDate(for: $1) }
        }

        var products = decodeProducts(from: documents)
        try await attachSellers(to: &products) // Overkill since it's the same seller, but conforms
        return products
    }

    private func createdAtDate(for document: DocumentSnapshot) -> Date {
        let raw = document.data()?["created_at"]

        if let timestamp = raw as? Timestamp {
            return timestamp.dateValue()
        }

        if let date = raw as? Date {
            return date
        }

        if let string = raw as? String {
            if let parsed = iso8601WithFractionalSeconds.date(from: string) ?? iso8601WithoutFractionalSeconds.date(from: string) {
                return parsed
            }
        }

        return .distantPast
    }

    /// Increments views_count by 1 using FieldValue.increment
    func incrementViewCount(productId: String) async throws {
        try await db.collection("products").document(productId).updateData([
            "views_count": FieldValue.increment(Int64(1))
        ])
        print("👁️ Product \(productId) view incremented")
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
