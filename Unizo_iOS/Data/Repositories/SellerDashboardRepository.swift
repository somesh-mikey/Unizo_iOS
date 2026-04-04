//
//  SellerDashboardRepository.swift
//  Unizo_iOS
//
//  Created for connecting SellerDashboard with real backend data
//

import Foundation
import FirebaseFirestore

// MARK: - Seller Statistics Model
struct SellerStatistics {
    let totalSales: Double
    let salesGoal: Double
    let itemsSold: Int
    let pendingOrders: Int
    let categoryBreakdown: [CategorySales]
    let upcomingPayment: UpcomingPayment?
}

struct CategorySales {
    let category: String
    let count: Int
    let color: String  // For pie chart coloring
}

struct UpcomingPayment {
    let amount: Double
    let dueDate: Date
    let buyerName: String
}

// MARK: - Seller Order Model (for dashboard display)
struct SellerOrder {
    let id: String
    let productId: String
    let buyerId: String?
    let category: String
    let title: String
    let status: OrderStatus
    let price: Double
    let imageUrl: String?
    let buyerName: String?
    let createdAt: Date

    var statusText: String {
        switch status {
        case .pending:
            return "Pending"
        case .confirmed:
            return "Confirmed"
        case .shipped:
            return "Shipped"
        case .delivered:
            return "Sold for"
        case .cancelled:
            return "Cancelled"
        }
    }

    var priceText: String {
        return "₹\(Int(price))"
    }
}

// MARK: - Repository
final class SellerDashboardRepository {

    private let db = Firestore.firestore()
    private let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    private let iso8601WithoutFractionalSeconds = ISO8601DateFormatter()

    init() {}

    private func decodeProduct(from document: DocumentSnapshot) -> ProductDTO? {
        guard var product = try? document.data(as: ProductDTO.self) else {
            return nil
        }

        if product.id == nil {
            product.id = document.documentID
        }

        return product
    }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> String {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(domain: "SellerDashboardRepository", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        return userId
    }

    // MARK: - Network Guard
    private func requireNetwork() throws {
        guard NetworkMonitor.shared.isReachable() else {
            throw NetworkError.noConnection
        }
    }

    // MARK: - Fetch Current User Profile
    func fetchSellerProfile() async throws -> UserDTO? {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let doc = try await db.collection("users").document(userId).getDocument()
        return try? doc.data(as: UserDTO.self)
    }

    // MARK: - Fetch Seller's Products
    func fetchSellerProducts() async throws -> [ProductDTO] {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let indexedQuery = db.collection("products")
            .whereField("seller_id", isEqualTo: userId)
            .order(by: "created_at", descending: true)

        do {
            let snapshot = try await indexedQuery.getDocuments()
            return snapshot.documents.compactMap { decodeProduct(from: $0) }
        } catch {
            print("⚠️ fetchSellerProducts indexed query failed, using fallback: \(error.localizedDescription)")

            // Fallback avoids requiring a composite index and sorts in memory.
            let fallbackSnapshot = try await db.collection("products")
                .whereField("seller_id", isEqualTo: userId)
                .getDocuments()

            let sortedDocuments = fallbackSnapshot.documents.sorted {
                createdAtDate(for: $0) > createdAtDate(for: $1)
            }

            return sortedDocuments.compactMap { decodeProduct(from: $0) }
        }
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

    // MARK: - Fetch Orders Where Seller's Products Were Ordered
    func fetchSellerOrders() async throws -> [SellerOrder] {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        // 1. Fetch products owned by seller
        let products = try await fetchSellerProducts()
        let productIds = products.compactMap { $0.id }
        
        guard !productIds.isEmpty else { return [] }
        
        // 2. Fetch order items that map to these products (Chunked by 10)
        var orderItems: [OrderItemDTO] = []
        let chunks = productIds.chunked(into: 10)
        
        for chunk in chunks {
            let itemSnapshot = try await db.collection("order_items")
                .whereField("product_id", in: chunk)
                .getDocuments()
            
            let dtos = itemSnapshot.documents.compactMap { try? $0.data(as: OrderItemDTO.self) }
            orderItems.append(contentsOf: dtos)
        }
        
        guard !orderItems.isEmpty else { return [] }
        
        // 3. Fetch associated orders
        let orderIds = Array(Set(orderItems.map { $0.order_id }))
        var orders: [String: OrderDTO] = [:]
        
        for oChunk in orderIds.chunked(into: 10) {
            let orderSnapshot = try await db.collection("orders")
                .whereField(FieldPath.documentID(), in: oChunk)
                .getDocuments()
                
            for doc in orderSnapshot.documents {
                if let dto = try? doc.data(as: OrderDTO.self) {
                    orders[doc.documentID] = dto
                }
            }
        }
        
        // 4. Fetch buyer details
        let buyerIds = Array(Set(orders.values.map { $0.user_id }))
        var buyers: [String: UserDTO] = [:]
        
        for bChunk in buyerIds.chunked(into: 10) {
            let userSnapshot = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: bChunk)
                .getDocuments()
                
            for doc in userSnapshot.documents {
                if let dto = try? doc.data(as: UserDTO.self) {
                    buyers[doc.documentID] = dto
                }
            }
        }
        
        // 5. Assemble to SellerOrder
        var sellerOrders: [SellerOrder] = []
        
        let dateFormatter = ISO8601DateFormatter()
        
        for item in orderItems {
            let productId = item.product_id
            guard let product = products.first(where: { $0.id == productId }),
                  let order = orders[item.order_id] else { continue }
            
            let buyer = buyers[order.user_id]
            
            sellerOrders.append(SellerOrder(
                id: item.id ?? UUID().uuidString,
                productId: productId,
                buyerId: order.user_id,
                category: product.category ?? "General",
                title: product.title,
                status: OrderStatus(rawValue: order.status) ?? .pending,
                price: item.price_at_purchase,
                imageUrl: product.imageUrl,
                buyerName: buyer?.displayName ?? "Buyer",
                createdAt: dateFormatter.date(from: order.created_at) ?? dateFormatter.date(from: order.created_at.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)) ?? Date()
            ))
        }

        return sellerOrders.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Calculate Seller Statistics
    func fetchSellerStatistics() async throws -> SellerStatistics {
        let orders = try await fetchSellerOrders()

        // Calculate total sales (from delivered orders)
        let deliveredOrders = orders.filter { $0.status == .delivered }
        let totalSales = deliveredOrders.reduce(0.0) { $0 + $1.price }

        // Items sold count
        let itemsSold = deliveredOrders.count

        // Pending orders count
        let pendingOrders = orders.filter { $0.status == .pending || $0.status == .confirmed }.count

        // Category breakdown (from all orders)
        var categoryCount: [String: Int] = [:]
        for order in orders {
            categoryCount[order.category, default: 0] += 1
        }

        let categoryColors: [String: String] = [
            "Hostel Essentials": "systemGreen",
            "Fashion": "systemBlue",
            "Sports": "systemYellow",
            "Gadgets": "systemRed",
            "Furniture": "systemPurple",
            "Electronics": "systemOrange"
        ]

        let categoryBreakdown = categoryCount.map { category, count in
            CategorySales(
                category: category,
                count: count,
                color: categoryColors[category] ?? "systemGray"
            )
        }.sorted { $0.count > $1.count }

        // Upcoming payment (first pending order)
        let pendingPaymentOrder = orders.first { $0.status == .pending || $0.status == .confirmed }
        let upcomingPayment: UpcomingPayment? = pendingPaymentOrder.map { order in
            UpcomingPayment(
                amount: order.price,
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: order.createdAt) ?? order.createdAt,
                buyerName: order.buyerName ?? "Buyer"
            )
        }

        return SellerStatistics(
            totalSales: totalSales,
            salesGoal: 5000.0,
            itemsSold: itemsSold,
            pendingOrders: pendingOrders,
            categoryBreakdown: categoryBreakdown,
            upcomingPayment: upcomingPayment
        )
    }
}
