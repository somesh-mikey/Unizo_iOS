//
//  OrderItem.swift
//  Unizo_iOS
//
//  Simple model for passing product data through the order flow
//

import Foundation

/// Represents an item in an order (replacing CartItem)
struct OrderItem {
    let product: ProductUIModel
    let quantity: Int

    init(product: ProductUIModel, quantity: Int = 1) {
        self.product = product
        self.quantity = quantity
    }

    var totalPrice: Double {
        return product.price * Double(quantity)
    }
}
