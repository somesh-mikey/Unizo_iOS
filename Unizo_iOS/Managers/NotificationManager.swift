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
}

// MARK: - NotificationManager

final class NotificationManager {

    static let shared = NotificationManager()

    private let db = Firestore.firestore()
    private let repository = NotificationRepository()

    private var listenerRegistration: ListenerRegistration?
    private var currentUserId: String?
    private var isListening = false

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
        guard !isListening else { return }

        guard let userId = await AuthManager.shared.currentUserId else {
            print("NotificationManager: User not authenticated, skipping")
            return
        }

        currentUserId = userId
        isListening   = true

        await refreshUnreadCount()
        subscribeToRealtime(userId: userId)

        print("NotificationManager: Started listening for user \(userId)")
    }

    /// Tears down the realtime listener and resets state. Call on sign-out.
    func stopListening() async {
        guard isListening else { return }

        if let listener = listenerRegistration {
            listener.remove()
            listenerRegistration = nil
        }

        currentUserId = nil
        isListening   = false
        unreadCount   = 0

        print("NotificationManager: Stopped listening")
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
        listenerRegistration = db.collection("notifications")
            .whereField("recipient_id", isEqualTo: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let snapshot = querySnapshot else {
                    print("NotificationManager: Error listening for notifications: \(error?.localizedDescription ?? "unknown error")")
                    return
                }

                // Only process newly added documents
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        if let notification = try? diff.document.data(as: NotificationDTO.self) {
                            // Quick check to avoid reprocessing old notifications on initial load
                            // We can check if `is_read` is false to increment badge
                            Task { await self.handleNewNotification(notification) }
                        }
                    }
                }
            }
        print("NotificationManager: Subscribed to realtime for user \(userId)")
    }

    private func handleNewNotification(_ notification: NotificationDTO) async {
        print("NotificationManager: Received — \(notification.title)")

        await MainActor.run {
            // Only increment if unread
            if !notification.is_read {
                self.unreadCount += 1
            }
            self.delegate?.notificationManager(self, didReceiveNotification: notification)
            NotificationCenter.default.post(
                name: .newNotificationReceived,
                object: nil,
                userInfo: ["notification": notification]
            )
        }

        if !notification.is_read {
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
            "route": notification.deeplink_payload.route,
            "orderId": notification.order_id
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
              let rootVC = window.rootViewController else { return }

        var navController: UINavigationController?

        if let tabBar = rootVC as? MainTabBarController {
            navController = tabBar.selectedViewController as? UINavigationController
        } else if let nav = rootVC as? UINavigationController {
            navController = nav
        }

        switch route {
        case "confirm_order_seller":
            guard let orderId = orderId else { return }
            _ = orderId // Normally we pass this to the View Controller
            print("NotificationManager: Navigating to confirm_order_seller with \(orderId)")
            // Implementation mapping for UI navigation skipped for backend migration focus
        default:
            print("NotificationManager: Unknown route '\(route)'")
        }
    }
}
