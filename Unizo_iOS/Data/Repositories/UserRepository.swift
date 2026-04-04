//
//  UserRepository.swift
//  Unizo_iOS
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class UserRepository {

    private let db = Firestore.firestore()

    init() { }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> String {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(domain: "UserRepository", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        return userId
    }

    // MARK: - Network Guard
    private func requireNetwork() throws {
        guard NetworkMonitor.shared.isReachable() else {
            throw NetworkError.noConnection
        }
    }

    // MARK: - Fetch Current User Profile
    func fetchCurrentUser() async throws -> UserDTO? {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let document = try await db.collection("users").document(userId).getDocument()
        if document.exists {
            return try document.data(as: UserDTO.self)
        } else {
            return nil
        }
    }

    // MARK: - Fetch Any User By ID
    func fetchUser(id: String) async throws -> UserDTO? {
        try requireNetwork()
        let document = try await db.collection("users").document(id).getDocument()
        guard document.exists else { return nil }
        return try document.data(as: UserDTO.self)
    }

    // MARK: - Update User Preferences (notifications)
    func updatePreferences(emailNotifications: Bool?, smsNotifications: Bool?) async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        var updateData: [String: Any] = [:]
        if let emailNotifications = emailNotifications {
            updateData["email_notifications"] = emailNotifications
        }
        if let smsNotifications = smsNotifications {
            updateData["sms_notifications"] = smsNotifications
        }

        guard !updateData.isEmpty else { return }

        try await db.collection("users").document(userId).setData(updateData, merge: true)
    }

    // MARK: - Update User Profile
    // NOTE: UserProfileUpdate structure is assumed to be encodable. 
    // We convert it to a dictionary so Firestore updateData works without overwriting existing unaffected fields.
    func updateProfile(_ update: UserProfileUpdate) async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let data = try Firestore.Encoder().encode(update)
        try await db.collection("users").document(userId).setData(data, merge: true)
    }

    // MARK: - Update Profile Image URL
    func updateProfileImageURL(_ url: String) async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        try await db.collection("users").document(userId).setData([
            "profile_image_url": url
        ], merge: true)
    }

    // MARK: - Ensure Current User Profile Exists
    /// Creates or updates the current user profile with the minimum
    /// required identity fields so Account/Profile can always render.
    func ensureCurrentUserProfile(seedEmail: String? = nil) async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let authUser = Auth.auth().currentUser
        let resolvedEmail = authUser?.email ?? seedEmail
        let resolvedPhone = authUser?.phoneNumber
        let displayName = authUser?.displayName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        var firstName = ""
        var lastName = ""
        if !displayName.isEmpty {
            let parts = displayName
                .split(separator: " ", omittingEmptySubsequences: true)
                .map(String.init)
            if let first = parts.first {
                firstName = first
                if parts.count > 1 {
                    lastName = parts.dropFirst().joined(separator: " ")
                }
            }
        }

        var payload: [String: Any] = [
            "role": "buyer",
            "email_notifications": true,
            "sms_notifications": false,
            "created_at": ISO8601DateFormatter().string(from: Date())
        ]

        if let resolvedEmail, !resolvedEmail.isEmpty {
            payload["email"] = resolvedEmail
        }
        if let resolvedPhone, !resolvedPhone.isEmpty {
            payload["phone"] = resolvedPhone
        }
        if !firstName.isEmpty {
            payload["first_name"] = firstName
        }
        if !lastName.isEmpty {
            payload["last_name"] = lastName
        }

        try await db.collection("users").document(userId).setData(payload, merge: true)
    }
}
