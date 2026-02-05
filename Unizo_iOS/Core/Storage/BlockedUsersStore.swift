//
//  BlockedUsersStore.swift
//  Unizo_iOS
//
//  Local storage for blocked users (App Store requirement)
//  This provides immediate blocking even if backend fails
//

import Foundation

enum BlockedUsersStore {
    private static let key = "blocked_user_ids"

    /// Returns all blocked user IDs
    static func all() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
    }

    /// Add a user ID to the blocked list
    static func add(_ userId: String) {
        var set = all()
        set.insert(userId)
        UserDefaults.standard.set(Array(set), forKey: key)
        print("🚫 Blocked user: \(userId)")
    }

    /// Remove a user ID from the blocked list (unblock)
    static func remove(_ userId: String) {
        var set = all()
        set.remove(userId)
        UserDefaults.standard.set(Array(set), forKey: key)
        print("✅ Unblocked user: \(userId)")
    }

    /// Check if a user is blocked
    static func isBlocked(_ userId: String) -> Bool {
        all().contains(userId)
    }

    /// Clear all blocked users
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
