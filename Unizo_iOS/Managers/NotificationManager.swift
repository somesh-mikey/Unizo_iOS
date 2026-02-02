//
//  NotificationManager.swift
//  Unizo_iOS
//

import Foundation
import UIKit
import Supabase

// MARK: - Notification Manager Delegate
protocol NotificationManagerDelegate: AnyObject {
    func notificationManager(_ manager: NotificationManager, didReceiveNotification notification: NotificationDTO)
    func notificationManager(_ manager: NotificationManager, didUpdateUnreadCount count: Int)
}

// MARK: - Notification Names
extension Notification.Name {
    static let notificationUnreadCountChanged = Notification.Name("notificationUnreadCountChanged")
    static let newNotificationReceived = Notification.Name("newNotificationReceived")
}

// MARK: - Notification Manager
final class NotificationManager {

    static let shared = NotificationManager()

    private let client = SupabaseManager.shared.client
    private let repository = NotificationRepository()

    private var realtimeChannel: RealtimeChannelV2?
    private var currentUserId: UUID?
    private var isListening = false

    weak var delegate: NotificationManagerDelegate?

    // Published unread count
    private(set) var unreadCount: Int = 0 {
        didSet {
            delegate?.notificationManager(self, didUpdateUnreadCount: unreadCount)
            // Post notification for UIKit observers
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

    // MARK: - Start Listening (Call on Login)
    func startListening() async {
        // Prevent duplicate subscriptions
        guard !isListening else {
            print("NotificationManager: Already listening")
            return
        }

        guard let userId = await AuthManager.shared.currentUserId else {
            print("NotificationManager: User not authenticated, skipping")
            return
        }

        currentUserId = userId
        isListening = true

        // Fetch initial unread count
        await refreshUnreadCount()

        // Subscribe to Realtime
        await subscribeToRealtime(userId: userId)

        print("NotificationManager: Started listening for user \(userId)")
    }

    // MARK: - Stop Listening (Call on Logout)
    func stopListening() async {
        guard isListening else { return }

        if let channel = realtimeChannel {
            await client.realtimeV2.removeChannel(channel)
            realtimeChannel = nil
        }

        currentUserId = nil
        isListening = false
        unreadCount = 0

        print("NotificationManager: Stopped listening")
    }

    // MARK: - Subscribe to Realtime
    private func subscribeToRealtime(userId: UUID) async {
        let channel = client.realtimeV2.channel("notifications:\(userId.uuidString)")

        // CRITICAL: Filter to only this user's notifications
        let insertions = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "notifications",
            filter: "recipient_id=eq.\(userId.uuidString)"
        )

        // Handle new notifications
        Task {
            for await insertion in insertions {
                await handleNewNotification(insertion)
            }
        }

        // Subscribe to channel
        await channel.subscribe()
        realtimeChannel = channel

        print("NotificationManager: Subscribed to realtime for user \(userId)")
    }

    // MARK: - Handle New Notification
    private func handleNewNotification(_ insertion: InsertAction) async {
        do {
            // Decode the notification from the realtime payload
            // Use JSONEncoder to convert the record to Data
            let encoder = JSONEncoder()
            let data = try encoder.encode(insertion.record)
            let decoder = JSONDecoder()
            let notification = try decoder.decode(NotificationDTO.self, from: data)

            print("NotificationManager: Received realtime notification - \(notification.title)")

            // Update unread count
            await MainActor.run {
                self.unreadCount += 1
            }

            // Notify delegate
            await MainActor.run {
                self.delegate?.notificationManager(self, didReceiveNotification: notification)
            }

            // Post notification for observers
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .newNotificationReceived,
                    object: nil,
                    userInfo: ["notification": notification]
                )
            }

            // Show in-app banner
            await showInAppBanner(for: notification)

        } catch {
            print("NotificationManager: Failed to decode notification: \(error)")
        }
    }

    // MARK: - Show In-App Banner
    @MainActor
    private func showInAppBanner(for notification: NotificationDTO) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        let bannerView = InAppNotificationBanner(
            title: notification.title,
            message: notification.message,
            orderId: notification.order_id
        )

        bannerView.onTap = { [weak self] orderId in
            self?.navigateToOrder(notification: notification)
        }

        // Add banner to window
        window.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = bannerView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: -120)

        NSLayoutConstraint.activate([
            topConstraint,
            bannerView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
            bannerView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
            bannerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])

        window.layoutIfNeeded()

        // Animate in
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            topConstraint.constant = 8
            window.layoutIfNeeded()
        }

        // Auto-dismiss after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                topConstraint.constant = -120
                window.layoutIfNeeded()
            } completion: { _ in
                bannerView.removeFromSuperview()
            }
        }
    }

    // MARK: - Navigate from Notification (using deeplink_payload)
    @MainActor
    private func navigateToOrder(notification: NotificationDTO) {
        let payload = notification.deeplink_payload

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            return
        }

        // Find the navigation controller
        var navController: UINavigationController?

        if let tabBar = rootVC as? MainTabBarController {
            navController = tabBar.selectedViewController as? UINavigationController
        } else if let nav = rootVC as? UINavigationController {
            navController = nav
        }

        // Route based on deeplink payload
        switch payload.route {
        case "confirm_order_seller":
            guard let orderId = payload.orderId else { return }
            let vc = ConfirmOrderSellerViewController()
            vc.orderId = orderId

            if let nav = navController {
                nav.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                rootVC.present(vc, animated: true)
            }

        default:
            print("NotificationManager: Unknown route \(payload.route)")
        }
    }

    // MARK: - Refresh Unread Count
    func refreshUnreadCount() async {
        do {
            let count = try await repository.fetchUnreadCount()
            await MainActor.run {
                self.unreadCount = count
            }
        } catch {
            print("NotificationManager: Failed to fetch unread count: \(error)")
        }
    }

    // MARK: - Mark as Read
    func markAsRead(notificationId: UUID) async {
        do {
            try await repository.markAsRead(notificationId: notificationId)
            await MainActor.run {
                if self.unreadCount > 0 {
                    self.unreadCount -= 1
                }
            }
        } catch {
            print("NotificationManager: Failed to mark as read: \(error)")
        }
    }

    // MARK: - Mark All as Read
    func markAllAsRead() async {
        do {
            try await repository.markAllAsRead()
            await MainActor.run {
                self.unreadCount = 0
            }
        } catch {
            print("NotificationManager: Failed to mark all as read: \(error)")
        }
    }
}
