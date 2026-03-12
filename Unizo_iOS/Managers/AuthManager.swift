//
//  AuthManager.swift
//  Unizo_iOS
//
//  Thin wrapper around the Supabase Auth API. Provides async and sync
//  accessors for the current user session, plus higher-level operations
//  like password change and full account deletion.
//

import Foundation
import Supabase

final class AuthManager {
    static let shared = AuthManager()

    private let supabase = SupabaseManager.shared.client

    private init() {}

    // MARK: - Session Accessors

    /// Async — fetches the live session from Supabase. Returns nil if no session exists.
    var currentUserId: UUID? {
        get async {
            do {
                return try await supabase.auth.session.user.id
            } catch {
                print("⚠️ No active session:", error)
                return nil
            }
        }
    }

    /// Synchronous — reads from the SDK's in-memory session cache.
    /// Use only when async context is unavailable; may be stale after token refresh.
    var currentUserIdSync: UUID? {
        try? supabase.auth.currentSession?.user.id
    }

    var currentUserEmail: String? {
        get async {
            try? await supabase.auth.session.user.email
        }
    }

    var isLoggedIn:     Bool { get async { await currentUserId != nil } }
    var isLoggedInSync: Bool { currentUserIdSync != nil }

    // MARK: - Password Management

    /// Re-authenticates with `oldPassword` then updates to `newPassword`.
    /// Throws if the current email can't be retrieved or the old password is wrong.
    func changePassword(oldPassword: String, newPassword: String) async throws {
        guard let email = try? await supabase.auth.session.user.email else {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "Unable to retrieve your email. Please try again."
            ])
        }

        do {
            _ = try await supabase.auth.signIn(email: email, password: oldPassword)
        } catch {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "Old password is incorrect."
            ])
        }

        _ = try await supabase.auth.update(user: UserAttributes(password: newPassword))
    }

    func sendPasswordResetEmail(to email: String) async throws {
        print("📧 [AuthManager] Sending reset email to: \(email)")
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            print("✅ [AuthManager] Reset email sent successfully")
        } catch {
            print("❌ [AuthManager] Reset email failed: \(error)")
            throw error
        }
    }

    /// Updates password for an already-authenticated user (no old password required).
    func updatePassword(newPassword: String) async throws {
        _ = try await supabase.auth.update(user: UserAttributes(password: newPassword))
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    // MARK: - Account Deletion

    /// Permanently deletes all user data then signs out. Order matters:
    /// dependent rows (order_items, etc.) are removed before their parents.
    func deleteAccount() async throws {
        guard let userId = await currentUserId else {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }

        try await supabase.from("addresses").delete()
            .eq("user_id", value: userId.uuidString).execute()

        let orders: [OrderDTO] = try await supabase
            .from("orders").select("id")
            .eq("user_id", value: userId.uuidString)
            .execute().value

        for order in orders {
            try await supabase.from("order_items").delete()
                .eq("order_id", value: order.id.uuidString).execute()
        }

        try await supabase.from("orders").delete()
            .eq("user_id", value: userId.uuidString).execute()

        try await supabase.from("products").delete()
            .eq("seller_id", value: userId.uuidString).execute()

        try await supabase.from("notifications").delete()
            .eq("recipient_id", value: userId.uuidString).execute()

        try await supabase.from("wishlists").delete()
            .eq("user_id", value: userId.uuidString).execute()

        try await supabase.from("users").delete()
            .eq("id", value: userId.uuidString).execute()

        try await supabase.auth.signOut()

        print("✅ Account and all associated data deleted successfully")
    }
}
