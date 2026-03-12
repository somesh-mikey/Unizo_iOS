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

            await showInAppBanner(for: notification)

        } catch {
            print("NotificationManager: Failed to decode notification: \(error)")
        }
    }

    // MARK: - UI Helpers

    /// Displays a dismissible in-app banner over the key window, then
    /// auto-dismisses after 4 seconds.
    @MainActor
    private func showInAppBanner(for notification: NotificationDTO) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }

        let bannerView = InAppNotificationBanner(
            title: notification.title,
            message: notification.message,
            orderId: notification.order_id
        )

        bannerView.onTap = { [weak self] _ in
            self?.navigateToOrder(notification: notification)
        }

        window.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = bannerView.topAnchor.constraint(
            equalTo: window.safeAreaLayoutGuide.topAnchor, constant: -120)

        NSLayoutConstraint.activate([
            topConstraint,
            bannerView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
            bannerView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
            bannerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])

        window.layoutIfNeeded()

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            topConstraint.constant = 8
            window.layoutIfNeeded()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                topConstraint.constant = -120
                window.layoutIfNeeded()
            } completion: { _ in bannerView.removeFromSuperview() }
        }
    }

    /// Routes the user to the appropriate screen based on the notification's deeplink payload.
    @MainActor
    private func navigateToOrder(notification: NotificationDTO) {
        let payload = notification.deeplink_payload

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else { return }

        var navController: UINavigationController?

        if let tabBar = rootVC as? MainTabBarController {
            navController = tabBar.selectedViewController as? UINavigationController
        } else if let nav = rootVC as? UINavigationController {
            navController = nav
        }

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
            print("NotificationManager: Unknown route '\(payload.route)'")
        }
    }
}
