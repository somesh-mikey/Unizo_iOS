//
//  AuthManager.swift
//  Unizo_iOS
//
//  Centralized authentication manager for tracking current user state
//

import Foundation
import Supabase

final class AuthManager {
    static let shared = AuthManager()

    private let supabase = SupabaseManager.shared.client

    private init() {}

    // MARK: - Current User ID
    /// Returns the currently authenticated user's ID, or nil if not logged in
    var currentUserId: UUID? {
        get async {
            do {
                let session = try await supabase.auth.session
                return session.user.id
            } catch {
                print("⚠️ No active session:", error)
                return nil
            }
        }
    }

    /// Synchronous version - returns cached user ID or nil
    /// Use this when you need immediate access and can't use async
    var currentUserIdSync: UUID? {
        // Try to get from current session synchronously
        // This relies on Supabase SDK's internal session cache
        if let session = try? supabase.auth.currentSession {
            return session.user.id
        }
        return nil
    }

    // MARK: - Current User Email
    var currentUserEmail: String? {
        get async {
            do {
                let session = try await supabase.auth.session
                return session.user.email
            } catch {
                return nil
            }
        }
    }

    // MARK: - Auth State
    var isLoggedIn: Bool {
        get async {
            await currentUserId != nil
        }
    }

    var isLoggedInSync: Bool {
        currentUserIdSync != nil
    }

    // MARK: - Sign Out
    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    // MARK: - Delete Account
    func deleteAccount() async throws {
        // Get current user ID before deletion
        guard let userId = await currentUserId else {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ])
        }

        // Delete user data from database tables first
        // This ensures all user-related data is removed before the auth user is deleted

        // Delete user's addresses
        try await supabase
            .from("addresses")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()

        // Delete user's orders and order items
        // First get order IDs to delete related order_items
        let orders: [OrderDTO] = try await supabase
            .from("orders")
            .select("id")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        for order in orders {
            try await supabase
                .from("order_items")
                .delete()
                .eq("order_id", value: order.id.uuidString)
                .execute()
        }

        // Delete orders
        try await supabase
            .from("orders")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()

        // Delete user's products
        try await supabase
            .from("products")
            .delete()
            .eq("seller_id", value: userId.uuidString)
            .execute()

        // Delete user's notifications
        try await supabase
            .from("notifications")
            .delete()
            .eq("recipient_id", value: userId.uuidString)
            .execute()

        // Delete user's wishlist items
        try await supabase
            .from("wishlists")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()

        // Delete user profile from users table
        try await supabase
            .from("users")
            .delete()
            .eq("id", value: userId.uuidString)
            .execute()

        // Finally sign out (this also clears the session)
        try await supabase.auth.signOut()

        print("✅ User account and all associated data deleted successfully")
    }
}
