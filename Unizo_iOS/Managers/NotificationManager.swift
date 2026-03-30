//
//  NotificationManager.swift
//  Unizo_iOS
//
//  Singleton that owns the Supabase Realtime subscription for in-app
//  notifications. Call startListening() after sign-in and stopListening()
//  on sign-out. Consumers can either conform to the delegate or observe
//  the NotificationCenter names defined below.
//

import Foundation
import UIKit
import Supabase
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

    private let client     = SupabaseManager.shared.client
    private let repository = NotificationRepository()

    private var realtimeChannel: RealtimeChannelV2?
    private var currentUserId: UUID?
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
        await subscribeToRealtime(userId: userId)

        print("NotificationManager: Started listening for user \(userId)")
    }

    /// Tears down the realtime channel and resets state. Call on sign-out.
    func stopListening() async {
        guard isListening else { return }

        if let channel = realtimeChannel {
            await client.realtimeV2.removeChannel(channel)
            realtimeChannel = nil
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

    func markAsRead(notificationId: UUID) async {
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

    private func subscribeToRealtime(userId: UUID) async {
        let channel = client.realtimeV2.channel("notifications:\(userId.uuidString)")

        // Row-level filter so we only receive this user's rows, not every insert.
        let insertions = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "notifications",
            filter: "recipient_id=eq.\(userId.uuidString)"
        )

        Task {
            for await insertion in insertions {
                await handleNewNotification(insertion)
            }
        }

        await channel.subscribe()
        realtimeChannel = channel

        print("NotificationManager: Subscribed to realtime for user \(userId)")
    }

    private func handleNewNotification(_ insertion: InsertAction) async {
        do {
            let data = try JSONEncoder().encode(insertion.record)
            let notification = try JSONDecoder().decode(NotificationDTO.self, from: data)

            print("NotificationManager: Received — \(notification.title)")

            await MainActor.run {
                self.unreadCount += 1
                self.delegate?.notificationManager(self, didReceiveNotification: notification)
                NotificationCenter.default.post(
                    name: .newNotificationReceived,
                    object: nil,
                    userInfo: ["notification": notification]
                )
            }

            await scheduleLocalNotification(for: notification)

        } catch {
            print("NotificationManager: Failed to decode notification: \(error)")
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
            "orderId": notification.order_id.uuidString
        ]

        let request = UNNotificationRequest(
            identifier: "order-\(notification.id.uuidString)",
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
    func navigateToRoute(route: String, orderId: UUID?) {
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
            let vc = ConfirmOrderSellerViewController()
            vc.orderId = orderId

            if let nav = navController {
                nav.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                rootVC.present(vc, animated: true)
            }

        default:
            print("NotificationManager: Unknown route '\(route)'")
        }
    }
}
