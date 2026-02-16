//
//  OrderRealtimeManager.swift
//  Unizo_iOS
//

import Foundation
import Supabase

// MARK: - Notification Names
extension Notification.Name {
    /// Posted when a specific order's status changes in realtime.
    /// userInfo: ["orderId": UUID, "newStatus": String, "handoffCode": String?]
    static let orderStatusDidChange = Notification.Name("orderStatusDidChange")
}

// MARK: - Order Realtime Manager
/// Manages Supabase Realtime subscriptions for order status updates.
/// Subscribes per-order so both buyer and seller see updates instantly.
final class OrderRealtimeManager {

    static let shared = OrderRealtimeManager()

    private let client = SupabaseManager.shared.client

    /// Active channels keyed by order ID
    private var channels: [UUID: RealtimeChannelV2] = [:]

    private init() {}

    // MARK: - Subscribe to a Specific Order

    /// Call when opening OrderDetailsViewController. Safe to call multiple times
    /// for the same order — duplicates are ignored.
    func subscribeToOrder(_ orderId: UUID) async {
        guard channels[orderId] == nil else {
            print("OrderRealtime: Already subscribed to order \(orderId.uuidString.prefix(8))")
            return
        }

        let channel = client.realtimeV2.channel("order:\(orderId.uuidString)")

        // Listen for UPDATE events on this specific order row
        let updates = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "orders",
            filter: "id=eq.\(orderId.uuidString)"
        )

        // Handle updates in a background task
        Task { [weak self] in
            for await update in updates {
                self?.handleOrderUpdate(update, orderId: orderId)
            }
        }

        await channel.subscribe()
        channels[orderId] = channel

        print("OrderRealtime: Subscribed to order \(orderId.uuidString.prefix(8))")
    }

    // MARK: - Unsubscribe from a Specific Order

    /// Call when leaving OrderDetailsViewController.
    func unsubscribeFromOrder(_ orderId: UUID) async {
        guard let channel = channels[orderId] else { return }

        await client.realtimeV2.removeChannel(channel)
        channels[orderId] = nil

        print("OrderRealtime: Unsubscribed from order \(orderId.uuidString.prefix(8))")
    }

    // MARK: - Unsubscribe All (call on logout)

    func unsubscribeAll() async {
        for (orderId, channel) in channels {
            await client.realtimeV2.removeChannel(channel)
            print("OrderRealtime: Unsubscribed from order \(orderId.uuidString.prefix(8))")
        }
        channels.removeAll()
    }

    // MARK: - Handle Realtime Update

    /// Lightweight struct for decoding just the fields we need from the realtime record.
    private struct OrderRealtimeRecord: Codable {
        let id: UUID
        let status: String
        let handoff_code: String?
    }

    private func handleOrderUpdate(_ update: UpdateAction, orderId: UUID) {
        do {
            // Same encode→decode pattern used in NotificationManager / ChatManager
            let data = try JSONEncoder().encode(update.record)
            let record = try JSONDecoder().decode(OrderRealtimeRecord.self, from: data)

            let newStatus = record.status
            let handoffCode = record.handoff_code

            print("OrderRealtime: Order \(orderId.uuidString.prefix(8)) updated → status=\(newStatus), handoffCode=\(handoffCode ?? "nil")")

            // Post notification on main thread so UI observers can react
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .orderStatusDidChange,
                    object: nil,
                    userInfo: [
                        "orderId": orderId,
                        "newStatus": newStatus,
                        "handoffCode": handoffCode as Any
                    ]
                )
            }
        } catch {
            print("OrderRealtime: Failed to decode order update: \(error)")
        }
    }
}
