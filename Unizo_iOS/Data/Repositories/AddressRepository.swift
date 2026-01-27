//
//  AddressRepository.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/01/26.
//

import Foundation
import Supabase

struct AddressUpdatePayload: Encodable {
    let name: String
    let phone: String
    let line1: String
    let city: String
    let state: String
    let postal_code: String
    let country: String
    let is_default: Bool
}


final class AddressRepository {

    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> UUID {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(domain: "AddressRepository", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        return userId
    }

    func fetchAddresses() async throws -> [AddressDTO] {
        let userId = try await getCurrentUserId()

        return try await client
            .from("addresses")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("is_default", ascending: false)
            .execute()
            .value
    }

    func createAddress(_ address: AddressDTO) async throws {
        try await client
            .from("addresses")
            .insert(address)
            .execute()
    }

    func updateAddress(_ address: AddressDTO) async throws {
        let userId = try await getCurrentUserId()

        // If setting default → unset others for this user
        if address.is_default {
            struct DefaultReset: Encodable {
                let is_default: Bool
            }

            try await client
                .from("addresses")
                .update(DefaultReset(is_default: false))
                .eq("user_id", value: userId.uuidString)
                .neq("id", value: address.id.uuidString)
                .execute()
        }

        let payload = AddressUpdatePayload(
            name: address.name,
            phone: address.phone,
            line1: address.line1,
            city: address.city,
            state: address.state,
            postal_code: address.postal_code,
            country: address.country,
            is_default: address.is_default
        )

        try await client
            .from("addresses")
            .update(payload)
            .eq("id", value: address.id.uuidString)
            .execute()
    }


    func deleteAddress(id: UUID) async throws {
        try await client
            .from("addresses")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
