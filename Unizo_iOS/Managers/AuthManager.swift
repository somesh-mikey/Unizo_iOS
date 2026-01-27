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
}
