//
//  SellerDashboardRepository.swift
//  Unizo_iOS
//
//  Created for connecting SellerDashboard with real backend data
//

import Foundation
import Supabase

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
    let id: UUID
    let productId: UUID
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

    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> UUID {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(domain: "SellerDashboardRepository", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        return userId
    }

    // MARK: - Fetch Current User Profile
    func fetchSellerProfile() async throws -> UserDTO? {
        let userId = try await getCurrentUserId()

        let users: [UserDTO] = try await client
            .from("users")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        return users.first
    }

    // MARK: - Fetch Seller's Products
    func fetchSellerProducts() async throws -> [ProductDTO] {
        let userId = try await getCurrentUserId()

        let response = try await client
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
                condition,
                quantity,
                status,
                seller_id
            """)
            .eq("seller_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()

        return try JSONDecoder().decode([ProductDTO].self, from: response.data)
    }

    // MARK: - Fetch Orders Where Seller's Products Were Ordered
    func fetchSellerOrders() async throws -> [SellerOrder] {
        let userId = try await getCurrentUserId()

        // Fetch order items where the product belongs to the current seller
        // Simplified query without nested user join (Supabase may not have the FK relationship)
        struct SellerOrderItemDTO: Codable {
            let id: UUID
            let order_id: UUID
            let product_id: UUID
            let quantity: Int
            let price_at_purchase: Double
            let product: SellerProductInfo?
            let order: SellerOrderInfo?

            struct SellerProductInfo: Codable {
                let id: UUID
                let title: String
                let category: String?
                let image_url: String?
                let seller_id: UUID?  // Can be null for some products
            }

            struct SellerOrderInfo: Codable {
                let id: UUID
                let user_id: UUID
                let status: String
                let created_at: String
            }
        }

        let response = try await client
            .from("order_items")
            .select("""
                id,
                order_id,
                product_id,
                quantity,
                price_at_purchase,
                product:products!product_id(
                    id,
                    title,
                    category,
                    image_url,
                    seller_id
                ),
                order:orders!order_id(
                    id,
                    user_id,
                    status,
                    created_at
                )
            """)
            .execute()

        let items = try JSONDecoder().decode([SellerOrderItemDTO].self, from: response.data)

        // Filter to only include items where product belongs to current seller
        let sellerItems = items.filter { item in
            item.product?.seller_id == userId
        }

        // Collect unique buyer IDs to fetch their names
        let buyerIds = Set(sellerItems.compactMap { $0.order?.user_id })
        var buyerNames: [UUID: String] = [:]

        // Fetch buyer names if there are any
        if !buyerIds.isEmpty {
            struct BuyerInfo: Codable {
                let id: UUID
                let first_name: String?
                let last_name: String?
                let email: String?
            }

            do {
                let buyers: [BuyerInfo] = try await client
                    .from("users")
                    .select("id, first_name, last_name, email")
                    .in("id", values: buyerIds.map { $0.uuidString })
                    .execute()
                    .value

                for buyer in buyers {
                    let first = buyer.first_name ?? ""
                    let last = buyer.last_name ?? ""
                    let fullName = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
                    buyerNames[buyer.id] = fullName.isEmpty ? (buyer.email?.components(separatedBy: "@").first ?? "Buyer") : fullName
                }
            } catch {
                print("⚠️ Failed to fetch buyer names: \(error)")
            }
        }

        // Convert to SellerOrder models
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return sellerItems.compactMap { item -> SellerOrder? in
            guard let product = item.product,
                  let order = item.order else { return nil }

            let buyerName = buyerNames[order.user_id] ?? "Buyer"
            let createdAt = dateFormatter.date(from: order.created_at) ?? Date()

            return SellerOrder(
                id: item.id,
                productId: product.id,
                category: product.category ?? "General",
                title: product.title,
                status: OrderStatus(rawValue: order.status) ?? .pending,
                price: item.price_at_purchase,
                imageUrl: product.image_url,
                buyerName: buyerName,
                createdAt: createdAt
            )
        }.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Calculate Seller Statistics
    func fetchSellerStatistics() async throws -> SellerStatistics {
        let products = try await fetchSellerProducts()
        let orders = try await fetchSellerOrders()

        // Calculate total sales (from delivered orders)
        let deliveredOrders = orders.filter { $0.status == .delivered }
        let totalSales = deliveredOrders.reduce(0.0) { $0 + $1.price }

        // Items sold count
        let itemsSold = deliveredOrders.count

        // Pending orders count
        let pendingOrders = orders.filter { $0.status == .pending || $0.status == .confirmed }.count

        // Category breakdown (from all orders, not just delivered)
        var categoryCount: [String: Int] = [:]
        for order in orders {
            categoryCount[order.category, default: 0] += 1
        }

        // Map categories to colors
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

        // Sales goal (could be fetched from user preferences, using default for now)
        let salesGoal: Double = 5000.0

        return SellerStatistics(
            totalSales: totalSales,
            salesGoal: salesGoal,
            itemsSold: itemsSold,
            pendingOrders: pendingOrders,
            categoryBreakdown: categoryBreakdown,
            upcomingPayment: upcomingPayment
        )
    }
}
