//
//  UserRepository.swift
//  Unizo_iOS
//

import Foundation
import Supabase

final class UserRepository {

    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> UUID {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(domain: "UserRepository", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }
        return userId
    }

    // MARK: - Fetch Current User Profile
    func fetchCurrentUser() async throws -> UserDTO? {
        let userId = try await getCurrentUserId()

        let users: [UserDTO] = try await client
            .from("users")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        return users.first
    }

    // MARK: - Update User Preferences (notifications)
    func updatePreferences(emailNotifications: Bool?, smsNotifications: Bool?) async throws {
        let userId = try await getCurrentUserId()

        var payload = UserPreferencesUpdate()
        payload.email_notifications = emailNotifications
        payload.sms_notifications = smsNotifications

        try await client
            .from("users")
            .update(payload)
            .eq("id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Update User Profile
    func updateProfile(_ update: UserProfileUpdate) async throws {
        let userId = try await getCurrentUserId()

        try await client
            .from("users")
            .update(update)
            .eq("id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Update Profile Image URL
    func updateProfileImageURL(_ url: String) async throws {
        let userId = try await getCurrentUserId()

        struct ImageUpdate: Encodable {
            let profile_image_url: String
        }

        try await client
            .from("users")
            .update(ImageUpdate(profile_image_url: url))
            .eq("id", value: userId.uuidString)
            .execute()
    }
}
