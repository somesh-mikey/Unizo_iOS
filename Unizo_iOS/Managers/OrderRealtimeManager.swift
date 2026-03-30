//
//  OrderRealtimeManager.swift
//  Unizo_iOS
//
//  Manages per-order Supabase Realtime channels so both buyer and seller
//  see status changes immediately without polling.
//
//  Usage:
//    - Call subscribeToOrder(_:) when entering OrderDetailsViewController.
//    - Call unsubscribeFromOrder(_:) when leaving.
//    - Call unsubscribeAll() on sign-out.
//  Observe .orderStatusDidChange on NotificationCenter for UI updates.
//

import Foundation
import Supabase

// MARK: - Notification Name

extension Notification.Name {
    /// Posted on the main queue when an order's status changes.
    /// userInfo keys: "orderId" (UUID), "newStatus" (String), "handoffCode" (String?)
    static let orderStatusDidChange = Notification.Name("orderStatusDidChange")
}

// MARK: - OrderRealtimeManager

final class OrderRealtimeManager {

    static let shared = OrderRealtimeManager()

    private let client  = SupabaseManager.shared.client
    private var channels: [UUID: RealtimeChannelV2] = [:]

    private init() {}

    // MARK: - Subscription Lifecycle

    /// Subscribes to realtime updates for the given order. Duplicate calls for
    /// the same order ID are ignored.
    func subscribeToOrder(_ orderId: UUID) async {
        guard channels[orderId] == nil else { return }

        let channel = client.realtimeV2.channel("order:\(orderId.uuidString)")

        let updates = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "orders",
            filter: "id=eq.\(orderId.uuidString)"
        )

        Task { [weak self] in
            for await update in updates {
                self?.handleOrderUpdate(update, orderId: orderId)
            }
        }

        await channel.subscribe()
        channels[orderId] = channel

        print("OrderRealtime: Subscribed to order \(orderId.uuidString.prefix(8))")
    }

    func unsubscribeFromOrder(_ orderId: UUID) async {
        guard let channel = channels[orderId] else { return }
        await client.realtimeV2.removeChannel(channel)
        channels[orderId] = nil
        print("OrderRealtime: Unsubscribed from order \(orderId.uuidString.prefix(8))")
    }

    /// Removes all active order channels. Call on sign-out.
    func unsubscribeAll() async {
        for (orderId, channel) in channels {
            await client.realtimeV2.removeChannel(channel)
            print("OrderRealtime: Unsubscribed from order \(orderId.uuidString.prefix(8))")
        }
        channels.removeAll()
    }

    // MARK: - Update Handling

    /// Minimal decodable for the fields we care about from the realtime record.
    private struct OrderRealtimeRecord: Codable {
        let id: UUID
        let status: String
        let handoff_code: String?
    }

    private func handleOrderUpdate(_ update: UpdateAction, orderId: UUID) {
        do {
            // Encode the AnyJSON record to Data, then decode into our typed struct.
            let data   = try JSONEncoder().encode(update.record)
            let record = try JSONDecoder().decode(OrderRealtimeRecord.self, from: data)

            print("OrderRealtime: Order \(orderId.uuidString.prefix(8)) → status=\(record.status)")

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .orderStatusDidChange,
                    object: nil,
                    userInfo: [
                        "orderId":     orderId,
                        "newStatus":   record.status,
                        "handoffCode": record.handoff_code as Any
                    ]
                )
            }
        } catch {
            print("OrderRealtime: Failed to decode order update: \(error)")
        }
    }
}
