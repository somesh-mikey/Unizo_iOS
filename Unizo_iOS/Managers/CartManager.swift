//
//  CartManager.swift
//  Unizo_iOS
//
//  Created by Somesh on 05/01/26.
//

import Foundation

final class CartManager {

    static let shared = CartManager()
    private init() {}

    private(set) var items: [CartItem] = []

    func add(product: ProductUIModel, quantity: Int = 1) {
        // Don't add products that are already sold or out of stock
        guard product.isAvailable else {
            print("⚠️ Cannot add product \(product.id) to cart - not available")
            return
        }

        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
    }

    func remove(productId: UUID) {
        items.removeAll { $0.product.id == productId }
    }

    func clear() {
        items.removeAll()
    }

    var totalAmount: Double {
        items.reduce(0) {
            $0 + ($1.product.price * Double($1.quantity))
        }
    }

    // MARK: - Cart Validation

    /// Result of cart validation
    struct CartValidationResult {
        let availableItems: [CartItem]
        let unavailableItems: [CartItem]  // Items that are sold or out of stock
        var hasUnavailableItems: Bool { !unavailableItems.isEmpty }
    }

    /// Validates cart items against current product availability
    /// - Parameter productRepository: Repository to fetch current product status
    /// - Returns: Validation result with available and unavailable items
    func validateCart(productRepository: ProductRepository) async -> CartValidationResult {
        var availableItems: [CartItem] = []
        var unavailableItems: [CartItem] = []

        for item in items {
            do {
                if let product = try await productRepository.fetchProduct(id: item.product.id) {
                    let status = product.status ?? .available
                    let quantity = product.quantity ?? 0

                    if status == .sold || quantity == 0 {
                        unavailableItems.append(item)
                    } else if quantity < item.quantity {
                        // Product available but not enough quantity - still add but with warning
                        availableItems.append(item)
                    } else {
                        availableItems.append(item)
                    }
                } else {
                    // Product not found - treat as unavailable
                    unavailableItems.append(item)
                }
            } catch {
                print("⚠️ Failed to validate product \(item.product.id): \(error)")
                // On error, assume item is still available (fail gracefully)
                availableItems.append(item)
            }
        }

        return CartValidationResult(
            availableItems: availableItems,
            unavailableItems: unavailableItems
        )
    }

    /// Removes unavailable items from the cart
    /// - Parameter productIds: Product IDs to remove
    func removeUnavailableItems(productIds: [UUID]) {
        items.removeAll { productIds.contains($0.product.id) }
    }

    /// Removes all sold/unavailable products from cart
    func removeSoldProducts(_ soldProductIds: [UUID]) {
        let removedCount = items.filter { soldProductIds.contains($0.product.id) }.count
        items.removeAll { soldProductIds.contains($0.product.id) }

        if removedCount > 0 {
            print("🛒 Removed \(removedCount) sold products from cart")
        }
    }
}
