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
    let is_default: Bool
}


final class AddressRepository {

    private let client: SupabaseClient

    init(client: SupabaseClient = supabase) {
        self.client = client
    }

    func fetchAddresses() async throws -> [AddressDTO] {
        try await client
            .from("addresses")
            .select()
            .eq("user_id", value: AppConstants.TEMP_USER_ID.uuidString)
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

        // If setting default → unset others
        if address.is_default {
            struct DefaultReset: Encodable {
                let is_default: Bool
            }

            try await client
                .from("addresses")
                .update(DefaultReset(is_default: false))
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


