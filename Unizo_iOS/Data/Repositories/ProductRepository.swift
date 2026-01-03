//
//  ProductRepository.swift
//  Unizo_iOS
//
//  Created by Somesh on 03/01/26.
//

import Foundation
import Supabase

final class ProductRepository {

    private let supabase: SupabaseClient
    private let pageSize = 20

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    func fetchAllProducts(page: Int) async throws -> [ProductDTO] {
        let from = page * pageSize
        let to = from + pageSize - 1

        let response = try await supabase
            .from("products")
            .select()
            .range(from: from, to: to)
            .execute()

        return try JSONDecoder().decode(
            [ProductDTO].self,
            from: response.data
        )
    }

    func fetchPopularProducts() async throws -> [ProductDTO] {
        let response = try await supabase
            .from("products")
            .select()
            .order("views_count", ascending: false)
            .limit(pageSize)
            .execute()

        return try JSONDecoder().decode(
            [ProductDTO].self,
            from: response.data
        )
    }

    func fetchNegotiableProducts() async throws -> [ProductDTO] {
        let response = try await supabase
            .from("products")
            .select()
            .eq("is_negotiable", value: true)
            .execute()

        return try JSONDecoder().decode(
            [ProductDTO].self,
            from: response.data
        )
    }
}

