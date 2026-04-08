//
//  NotificationManager.swift
//  Unizo_iOS
//
//  Singleton that owns the Firestore Realtime subscription for in-app
//  notifications. Call startListening() after sign-in and stopListening()
//  on sign-out. Consumers can either conform to the delegate or observe
//  the NotificationCenter names defined below.
//

import Foundation
import UIKit
import FirebaseFirestore
import UserNotifications

// MARK: - Delegate

protocol NotificationManagerDelegate: AnyObject {
    func notificationManager(_ manager: NotificationManager, didReceiveNotification notification: NotificationDTO)
    func notificationManager(_ manager: NotificationManager, didUpdateUnreadCount count: Int)
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted on main queue whenever the unread badge count changes.
    /// userInfo: ["count": Int]
    static let notificationUnreadCountChanged = Notification.Name("notificationUnreadCountChanged")

    /// Posted on main queue when a new notification arrives in realtime.
    /// userInfo: ["notification": NotificationDTO]
    static let newNotificationReceived = Notification.Name("newNotificationReceived")

    /// Posted on main queue whenever blocked user IDs change.
    /// userInfo: ["blockedSellerId": String]
    static let blockedUsersDidChange = Notification.Name("blockedUsersDidChange")
}

// MARK: - NotificationManager

final class NotificationManager {

    static let shared = NotificationManager()

    private let db = Firestore.firestore()
    private let repository = NotificationRepository()

    private var listenerRegistration: ListenerRegistration?
    private var currentUserId: String?
    private var isListening = false

    /// Tracks whether the initial Firestore snapshot has been received.
    /// Firestore's `addSnapshotListener` fires immediately with ALL existing
    /// documents as `.added` on first attach. We skip that batch to avoid
    /// double-counting the unread count (already set by `refreshUnreadCount()`).
    private var didReceiveInitialSnapshot = false

    weak var delegate: NotificationManagerDelegate?

    /// Current unread count. Assigning a new value notifies the delegate
    /// and broadcasts .notificationUnreadCountChanged on the main queue.
    private(set) var unreadCount: Int = 0 {
        didSet {
            delegate?.notificationManager(self, didUpdateUnreadCount: unreadCount)
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .notificationUnreadCountChanged,
                    object: nil,
                    userInfo: ["count": self.unreadCount]
                )
            }
        }
    }

    private init() {}

    // MARK: - Public Interface

    /// Starts the realtime subscription and fetches the initial unread count.
    /// Safe to call on every login — duplicate calls are no-ops.
    func startListening() async {
        guard !isListening else {
            print("NotificationManager: Already listening — no-op")
            return
        }

        guard let userId = await AuthManager.shared.currentUserId else {
            print("❌ NotificationManager: Cannot start — user not authenticated")
            return
        }

        currentUserId = userId
        isListening   = true

        print("NotificationManager: Starting for user \(userId)")

        await refreshUnreadCount()
        subscribeToRealtime(userId: userId)

        print("NotificationManager: ✅ Fully started for user \(userId)")
    }

    /// Tears down the realtime listener and resets state. Call on sign-out.
    func stopListening() async {
        guard isListening else {
            print("NotificationManager: Not listening — stopListening is a no-op")
            return
        }

        if let listener = listenerRegistration {
            listener.remove()
            listenerRegistration = nil
            print("NotificationManager: Removed Firestore snapshot listener")
        }

        currentUserId = nil
        isListening   = false
        didReceiveInitialSnapshot = false
        unreadCount   = 0

        print("NotificationManager: ✅ Stopped")
    }

    func refreshUnreadCount() async {
        do {
            let count = try await repository.fetchUnreadCount()
            await MainActor.run { self.unreadCount = count }
        } catch {
            print("NotificationManager: Failed to fetch unread count: \(error)")
        }
    }

    func markAsRead(notificationId: String) async {
        do {
            try await repository.markAsRead(notificationId: notificationId)
            await MainActor.run {
                if self.unreadCount > 0 { self.unreadCount -= 1 }
            }
        } catch {
            print("NotificationManager: Failed to mark as read: \(error)")
        }
    }

    func markAllAsRead() async {
        do {
            try await repository.markAllAsRead()
            await MainActor.run { self.unreadCount = 0 }
        } catch {
            print("NotificationManager: Failed to mark all as read: \(error)")
        }
    }

    func resetUnreadCount() {
        DispatchQueue.main.async { self.unreadCount = 0 }
    }

    // MARK: - Realtime

    private func subscribeToRealtime(userId: String) {
        // Prevent duplicate subscriptions
        if listenerRegistration != nil {
            print("NotificationManager: Listener already exists — skipping duplicate subscribe")
            return
        }

        didReceiveInitialSnapshot = false

        listenerRegistration = db.collection("notifications")
            .whereField("recipient_id", isEqualTo: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let snapshot = querySnapshot else {
                    print("❌ NotificationManager: Snapshot listener error: \(error?.localizedDescription ?? "unknown")")
                    return
                }

                // Skip the initial snapshot — it contains ALL existing documents
                // as `.added`. The unread count is already set by refreshUnreadCount().
                guard self.didReceiveInitialSnapshot else {
                    self.didReceiveInitialSnapshot = true
                    print("NotificationManager: Initial snapshot received (\(snapshot.documents.count) existing docs) — skipped")
                    return
                }

                // Process only newly added documents (realtime inserts)
                for diff in snapshot.documentChanges where diff.type == .added {
                    if let notification = self.repository.decodeNotification(document: diff.document) {
                        Task { await self.handleNewNotification(notification) }
                    }
                }
            }

        print("NotificationManager: ✅ Subscribed to Firestore realtime for user \(userId)")
    }

    private func handleNewNotification(_ notification: NotificationDTO) async {
        print("🔔 [Stage 2 Complete] Realtime notification received: \(notification.title) (id: \(notification.id ?? "nil"))")

        await MainActor.run {
            // Only increment if unread
            if !notification.safeIsRead {
                self.unreadCount += 1
            }
            self.delegate?.notificationManager(self, didReceiveNotification: notification)
            NotificationCenter.default.post(
                name: .newNotificationReceived,
                object: nil,
                userInfo: ["notification": notification]
            )
        }

        if !notification.safeIsRead {
            await scheduleLocalNotification(for: notification)
        }
    }

    // MARK: - Local Notification Helpers

    private func scheduleLocalNotification(for notification: NotificationDTO) async {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = .default
        content.userInfo = [
            "type": "order",
            "route": notification.safeDeeplinkPayload.route,
            "orderId": notification.safeOrderId
        ]

        let request = UNNotificationRequest(
            identifier: "order-\(notification.id ?? UUID().uuidString)",
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("NotificationManager: Failed to schedule local notification: \(error)")
        }
    }

    /// Routes to a screen based on deeplink route information.
    @MainActor
    func navigateToRoute(route: String, orderId: String?) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            print("❌ NotificationManager: Cannot navigate — no key window")
            return
        }

        var navController: UINavigationController?

        if let tabBar = rootVC as? MainTabBarController {
            navController = tabBar.selectedViewController as? UINavigationController
        } else if let nav = rootVC as? UINavigationController {
            navController = nav
        }

        guard let nav = navController else {
            print("❌ NotificationManager: Cannot navigate — no UINavigationController found")
            return
        }

        switch route {
        case "confirm_order_seller":
            guard let orderId = orderId else {
                print("⚠️ NotificationManager: confirm_order_seller route missing orderId")
                return
            }
            let vc = ConfirmOrderSellerViewController()
            vc.orderId = orderId
            nav.pushViewController(vc, animated: true)
            print("NotificationManager: Navigated to ConfirmOrderSeller with \(orderId)")

        case "order_details":
            guard let orderId = orderId else {
                print("⚠️ NotificationManager: order_details route missing orderId")
                return
            }
            let vc = OrderDetailsViewController()
            vc.orderId = orderId
            nav.pushViewController(vc, animated: true)
            print("NotificationManager: Navigated to OrderDetails with \(orderId)")

        default:
            print("NotificationManager: Unknown route '\(route)'")
        }
    }
}
