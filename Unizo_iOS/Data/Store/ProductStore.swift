//
//  ProductStore.swift
//  Unizo_iOS
//
//  Created by Somesh on 05/01/26.
//

import Foundation

final class ProductStore {

    static let shared = ProductStore()
    private init() {}

    private(set) var products: [ProductUIModel] = []

    func setProducts(_ products: [ProductUIModel]) {
        self.products = products
    }

    /// Removes a single product by ID (e.g., after it is sold).
    func removeProduct(id: UUID) {
        products.removeAll { $0.id == id }
    }

    func products(for category: String?) -> [ProductUIModel] {
        guard let category else {
            return products.shuffled()
        }
        return products.filter { $0.category == category }
    }
}

