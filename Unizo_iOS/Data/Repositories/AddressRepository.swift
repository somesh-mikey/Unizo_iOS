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
        let userId = try await getCurrentUserId()

        // Check if user has any existing addresses
        let existingAddresses: [AddressDTO] = try await client
            .from("addresses")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        // If this is the first address, make it default
        var addressToInsert = address
        if existingAddresses.isEmpty {
            addressToInsert.is_default = true
        }

        try await client
            .from("addresses")
            .insert(addressToInsert)
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
        let userId = try await getCurrentUserId()

        // Fetch all addresses for this user
        let allAddresses: [AddressDTO] = try await client
            .from("addresses")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        // Prevent deletion if this is the only address
        guard allAddresses.count > 1 else {
            throw AddressError.cannotDeleteLastAddress
        }

        // Find the address to delete
        guard let addressToDelete = allAddresses.first(where: { $0.id == id }) else {
            throw AddressError.addressNotFound
        }

        // Prevent deletion of default address
        if addressToDelete.is_default {
            throw AddressError.cannotDeleteDefaultAddress
        }

        try await client
            .from("addresses")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Check if address can be deleted
    func canDeleteAddress(_ address: AddressDTO, totalAddressCount: Int) -> Bool {
        // Cannot delete if it's the only address
        if totalAddressCount <= 1 {
            return false
        }
        // Cannot delete if it's the default address
        if address.is_default {
            return false
        }
        return true
    }
}

// MARK: - Address Errors
enum AddressError: LocalizedError {
    case cannotDeleteLastAddress
    case cannotDeleteDefaultAddress
    case addressNotFound

    var errorDescription: String? {
        switch self {
        case .cannotDeleteLastAddress:
            return "You must have at least one address. This is your only address and cannot be deleted."
        case .cannotDeleteDefaultAddress:
            return "The default address cannot be deleted. Please set another address as default first."
        case .addressNotFound:
            return "Address not found."
        }
    }
}
