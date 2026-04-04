//
//  NotificationRepository.swift
//  Unizo_iOS
//
//  Data access layer for Notifications using Firestore.
//  Idempotency is native to Firestore using the eventKey as the DocumentID!
//

import Foundation
import FirebaseFirestore

final class NotificationRepository {

    private let db = Firestore.firestore()
    private let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    private let iso8601WithoutFractionalSeconds = ISO8601DateFormatter()

    init() { }

    // MARK: - Decode Helpers
    private func routeFallback(for type: String) -> String {
        type == NotificationType.newOrder.rawValue ? "confirm_order_seller" : "order_details"
    }

    private func isoString(from value: Any?) -> String {
        switch value {
        case let timestamp as Timestamp:
            return iso8601WithFractionalSeconds.string(from: timestamp.dateValue())
        case let date as Date:
            return iso8601WithFractionalSeconds.string(from: date)
        case let string as String:
            return string
        default:
            return iso8601WithFractionalSeconds.string(from: Date())
        }
    }

    private func date(fromIsoString value: String) -> Date {
        iso8601WithFractionalSeconds.date(from: value)
            ?? iso8601WithoutFractionalSeconds.date(from: value)
            ?? Date.distantPast
    }

    func decodeNotification(document: DocumentSnapshot) -> NotificationDTO? {
        guard let data = document.data() else { return nil }

        guard let recipientId = data["recipient_id"] as? String,
              let senderId = data["sender_id"] as? String else {
            return nil
        }

        let rawType = (data["type"] as? String) ?? NotificationType.newOrder.rawValue
        let orderIdFromRoot = data["order_id"] as? String
        let deeplinkDict = data["deeplink_payload"] as? [String: Any]
        let orderIdFromDeeplink = deeplinkDict?["order_id"] as? String

        guard let orderId = orderIdFromRoot ?? orderIdFromDeeplink else {
            return nil
        }

        let route = (deeplinkDict?["route"] as? String) ?? routeFallback(for: rawType)
        let sellerId = deeplinkDict?["seller_id"] as? String
        let deeplinkPayload = DeeplinkPayload(
            route: route,
            orderId: orderIdFromDeeplink ?? orderId,
            sellerId: sellerId
        )

        return NotificationDTO(
            id: document.documentID,
            recipient_id: recipientId,
            sender_id: senderId,
            order_id: orderId,
            type: rawType,
            title: (data["title"] as? String) ?? "Notification",
            message: (data["message"] as? String) ?? "",
            deeplink_payload: deeplinkPayload,
            event_key: data["event_key"] as? String,
            is_read: (data["is_read"] as? Bool) ?? false,
            created_at: isoString(from: data["created_at"]),
            sender: nil
        )
    }

    // MARK: - Get Current User ID
    private func getCurrentUserId() async throws -> String {
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

    // MARK: - Create Notification (with native idempotency)
    func createNotification(
        recipientId: String,
        senderId: String,
        orderId: String,
        type: NotificationType,
        title: String,
        message: String,
        deeplinkPayload: DeeplinkPayload
    ) async throws {
        try requireNetwork()
        // Use eventKey directly as the Firestore Document ID.
        // This guarantees idempotency natively because `.setData(merge: false)`
        // or `.setData` will just overwrite or initialize the same document!
        let eventKey = "\(type.rawValue)_\(orderId)_\(recipientId)"

        let currentUserId = try await getCurrentUserId()

        print("🔔 Creating notification:")
        print("   - Current User ID (auth.uid): \(currentUserId)")
        print("   - Sender ID: \(senderId)")
        print("   - Recipient ID: \(recipientId)")
        print("   - Order ID: \(orderId)")
        print("   - Type: \(type.rawValue)")
        print("   - Event Key (Doc ID): \(eventKey)")

        let payload = NotificationInsertDTO(
            id: eventKey,
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
            let data = try Firestore.Encoder().encode(payload)
            var payloadData = data
            payloadData["is_read"] = false
            payloadData["created_at"] = FieldValue.serverTimestamp()
            try await db.collection("notifications").document(eventKey).setData(payloadData)
            print("✅ Notification created successfully")
        } catch {
            print("❌ Notification creation failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Helper: Attach Senders
    private func attachSenders(to notifications: inout [NotificationDTO]) async throws {
        let uniqueSenderIds = Array(Set(notifications.map { $0.sender_id }))
        guard !uniqueSenderIds.isEmpty else { return }
        
        let chunks = uniqueSenderIds.chunked(into: 10)
        var usersMap: [String: UserDTO] = [:]
        
        for chunk in chunks {
            let snapshot = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            for doc in snapshot.documents {
                if let user = try? doc.data(as: UserDTO.self) {
                    usersMap[doc.documentID] = user
                }
            }
        }
        
        for index in notifications.indices {
            let senderId = notifications[index].sender_id
            if let user = usersMap[senderId] {
                notifications[index].sender = user
            }
        }
    }

    // MARK: - Fetch Notifications for Current User
    func fetchNotifications() async throws -> [NotificationDTO] {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let documents: [QueryDocumentSnapshot]

        do {
            let indexedSnapshot = try await db.collection("notifications")
                .whereField("recipient_id", isEqualTo: userId)
                .order(by: "created_at", descending: true)
                .getDocuments()
            documents = indexedSnapshot.documents
        } catch {
            print("⚠️ fetchNotifications indexed query failed, using fallback: \(error.localizedDescription)")
            let fallbackSnapshot = try await db.collection("notifications")
                .whereField("recipient_id", isEqualTo: userId)
                .getDocuments()
            documents = fallbackSnapshot.documents
        }

        var notifications = documents.compactMap { decodeNotification(document: $0) }
        notifications.sort { date(fromIsoString: $0.created_at) > date(fromIsoString: $1.created_at) }
        try await attachSenders(to: &notifications)
        return notifications
    }

    // MARK: - Fetch Unread Count
    func fetchUnreadCount() async throws -> Int {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        do {
            let snapshot = try await db.collection("notifications")
                .whereField("recipient_id", isEqualTo: userId)
                .whereField("is_read", isEqualTo: false)
                .count
                .getAggregation(source: .server)
            return Int(truncating: snapshot.count)
        } catch {
            print("⚠️ fetchUnreadCount aggregate query failed, using fallback: \(error.localizedDescription)")
            let fallbackSnapshot = try await db.collection("notifications")
                .whereField("recipient_id", isEqualTo: userId)
                .getDocuments()
            return fallbackSnapshot.documents.reduce(into: 0) { count, doc in
                let isRead = doc.data()["is_read"] as? Bool ?? false
                if !isRead { count += 1 }
            }
        }
    }

    // MARK: - Mark Notification as Read
    func markAsRead(notificationId: String) async throws {
        try requireNetwork()
        try await db.collection("notifications").document(notificationId).updateData([
            "is_read": true
        ])
    }

    // MARK: - Mark All Notifications as Read
    func markAllAsRead() async throws {
        try requireNetwork()
        let userId = try await getCurrentUserId()

        let snapshot = try await db.collection("notifications")
            .whereField("recipient_id", isEqualTo: userId)
            .whereField("is_read", isEqualTo: false)
            .getDocuments()

        let batch = db.batch()
        for doc in snapshot.documents {
            batch.updateData(["is_read": true], forDocument: doc.reference)
        }
        try await batch.commit()
    }

    // MARK: - Delete Notification
    func deleteNotification(notificationId: String) async throws {
        try await db.collection("notifications").document(notificationId).delete()
    }

    // MARK: - Delete All Notifications for Current User
    func deleteAllNotifications() async throws {
        let userId = try await getCurrentUserId()

        let snapshot = try await db.collection("notifications")
            .whereField("recipient_id", isEqualTo: userId)
            .getDocuments()

        let batch = db.batch()
        // Note: Firestore batches are limited to 500 ops.
        // Assuming user has < 500 notifications, otherwise needs chunking.
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        try await batch.commit()
    }
}
