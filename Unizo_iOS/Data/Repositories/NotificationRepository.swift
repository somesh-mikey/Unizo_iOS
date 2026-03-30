//
//  NotificationRepository.swift
//  Unizo_iOS
//

import Foundation
import Supabase

final class NotificationRepository {

    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> UUID {
        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(domain: "NotificationRepository", code: 401, userInfo: [
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

    // MARK: - Create Notification (with idempotency)
    func createNotification(
        recipientId: UUID,
        senderId: UUID,
        orderId: UUID,
        type: NotificationType,
        title: String,
        message: String,
        deeplinkPayload: DeeplinkPayload
    ) async throws {
        try requireNetwork()
        // Generate event_key for idempotency (prevents duplicates)
        let eventKey = "\(type.rawValue):\(orderId.uuidString):\(recipientId.uuidString)"

        // Get current user for debugging
        let currentUserId = try await getCurrentUserId()

        print("🔔 Creating notification:")
        print("   - Current User ID (auth.uid): \(currentUserId.uuidString)")
        print("   - Sender ID: \(senderId.uuidString)")
        print("   - Recipient ID: \(recipientId.uuidString)")
        print("   - Order ID: \(orderId.uuidString)")
        print("   - Type: \(type.rawValue)")
        print("   - Event Key: \(eventKey)")
        print("   - sender_id == auth.uid: \(senderId == currentUserId)")

        let payload = NotificationInsertDTO(
            id: UUID(),
            recipient_id: recipientId,
            sender_id: senderId,
            order_id: orderId,
            type: type.rawValue,
            title: title,
            message: message,
            deeplink_payload: deeplinkPayload,
            event_key: eventKey
        )

        do {
            // Upsert with ON CONFLICT DO NOTHING for idempotency
            try await client
                .from("notifications")
                .upsert(payload, onConflict: "event_key")
                .execute()
            print("✅ Notification created successfully")
        } catch {
            print("❌ Notification creation failed: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Fetch Notifications for Current User
    func fetchNotifications() async throws -> [NotificationDTO] {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let response: [NotificationDTO] = try await client
            .from("notifications")
            .select("""
                id,
                recipient_id,
                sender_id,
                order_id,
                type,
                title,
                message,
                deeplink_payload,
                event_key,
                is_read,
                created_at,
                sender:users!sender_id(id, first_name, last_name, email)
            """)
            .eq("recipient_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Fetch Unread Count
    func fetchUnreadCount() async throws -> Int {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let response = try await client
            .from("notifications")
            .select("id", head: true, count: .exact)
            .eq("recipient_id", value: userId.uuidString)
            .eq("is_read", value: false)
            .execute()

        return response.count ?? 0
    }

    // MARK: - Mark Notification as Read
    func markAsRead(notificationId: UUID) async throws {
        try requireNetwork()
        struct ReadUpdate: Encodable {
            let is_read: Bool
        }

        try await client
            .from("notifications")
            .update(ReadUpdate(is_read: true))
            .eq("id", value: notificationId.uuidString)
            .execute()
    }

    // MARK: - Mark All Notifications as Read
    func markAllAsRead() async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        struct ReadUpdate: Encodable {
            let is_read: Bool
        }

        try await client
            .from("notifications")
            .update(ReadUpdate(is_read: true))
            .eq("recipient_id", value: userId.uuidString)
            .eq("is_read", value: false)
            .execute()
    }

    // MARK: - Delete Notification
    func deleteNotification(notificationId: UUID) async throws {
        try await client
            .from("notifications")
            .delete()
            .eq("id", value: notificationId.uuidString)
            .execute()
    }

    // MARK: - Delete All Notifications for Current User
    func deleteAllNotifications() async throws {
        let userId = try await getCurrentUserId()

        try await client
            .from("notifications")
            .delete()
            .eq("recipient_id", value: userId.uuidString)
            .execute()
    }
}
