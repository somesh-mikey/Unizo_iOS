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
}
