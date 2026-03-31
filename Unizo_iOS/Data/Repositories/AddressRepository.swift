//
//  AddressRepository.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/01/26.
//

import Foundation
import FirebaseFirestore

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

struct AddressInsertPayload: Encodable {
    let user_id: String
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

    private let db = Firestore.firestore()

    init() { }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> String {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(domain: "AddressRepository", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        return userId
    }
    
    // MARK: - Address Subcollection Ref
    private func addressesCollection(for userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("addresses")
    }

    // MARK: - Network Guard
    private func requireNetwork() throws {
        guard NetworkMonitor.shared.isReachable() else {
            throw NetworkError.noConnection
        }
    }

    func fetchAddresses() async throws -> [AddressDTO] {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let snapshot = try await addressesCollection(for: userId)
            .order(by: "is_default", descending: true)
            .getDocuments()
            
        return snapshot.documents.compactMap { try? $0.data(as: AddressDTO.self) }
    }

    func createAddress(_ address: AddressDTO) async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let snapshot = try await addressesCollection(for: userId).getDocuments()
        let existingAddresses = snapshot.documents

        var isDefault = address.is_default
        if existingAddresses.isEmpty {
            isDefault = true
        } else if address.is_default {
            try await unsetDefaults(for: userId)
        }

        let payload = AddressInsertPayload(
            user_id: userId,
            name: address.name,
            phone: address.phone,
            line1: address.line1,
            city: address.city,
            state: address.state,
            postal_code: address.postal_code,
            country: address.country,
            is_default: isDefault
        )

        let data = try Firestore.Encoder().encode(payload)
        try await addressesCollection(for: userId).addDocument(data: data)
    }

    func updateAddress(_ address: AddressDTO) async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()
        guard let addressId = address.id else { throw AddressError.addressNotFound }

        if address.is_default {
            try await unsetDefaults(for: userId, excluding: addressId)
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
        
        let data = try Firestore.Encoder().encode(payload)
        try await addressesCollection(for: userId).document(addressId).updateData(data)
    }

    private func unsetDefaults(for userId: String, excluding addressId: String? = nil) async throws {
        let snapshot = try await addressesCollection(for: userId)
            .whereField("is_default", isEqualTo: true)
            .getDocuments()
            
        let batch = db.batch()
        for doc in snapshot.documents {
            if doc.documentID != addressId {
                batch.updateData(["is_default": false], forDocument: doc.reference)
            }
        }
        try await batch.commit()
    }

    func deleteAddress(id: String) async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let snapshot = try await addressesCollection(for: userId).getDocuments()
        let allAddresses = snapshot.documents.compactMap { try? $0.data(as: AddressDTO.self) }

        guard allAddresses.count > 1 else {
            throw AddressError.cannotDeleteLastAddress
        }

        guard let addressToDelete = allAddresses.first(where: { $0.id == id }) else {
            throw AddressError.addressNotFound
        }

        if addressToDelete.is_default {
            throw AddressError.cannotDeleteDefaultAddress
        }

        try await addressesCollection(for: userId).document(id).delete()
    }

    func canDeleteAddress(_ address: AddressDTO, totalAddressCount: Int) -> Bool {
        if totalAddressCount <= 1 { return false }
        if address.is_default { return false }
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
            return "You must have at least one hotspot. This is your only hotspot and cannot be deleted."
        case .cannotDeleteDefaultAddress:
            return "The default hotspot cannot be deleted. Please set another hotspot as default first."
        case .addressNotFound:
            return "Hotspot not found."
        }
    }
}
