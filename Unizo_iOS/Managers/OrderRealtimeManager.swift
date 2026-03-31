//
//  OrderRealtimeManager.swift
//  Unizo_iOS
//
//  Manages per-order Firestore Snapshot Listeners so both buyer and 
//  seller see status changes immediately without polling.
//

import Foundation
import FirebaseFirestore

// MARK: - Notification Name

extension Notification.Name {
    /// Posted on the main queue when an order's status changes.
    /// userInfo keys: "orderId" (String), "newStatus" (String), "handoffCode" (String?)
    static let orderStatusDidChange = Notification.Name("orderStatusDidChange")
}

// MARK: - OrderRealtimeManager

final class OrderRealtimeManager {

    static let shared = OrderRealtimeManager()

    private let db = Firestore.firestore()
    private var listeners: [String: ListenerRegistration] = [:]

    private init() {}

    // MARK: - Subscription Lifecycle

    /// Subscribes to realtime updates for the given order. Duplicate calls for
    /// the same order ID are ignored.
    func subscribeToOrder(_ orderId: String) {
        guard listeners[orderId] == nil else { return }

        let listener = db.collection("orders").document(orderId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let document = documentSnapshot, document.exists else {
                    print("OrderRealtime: Error fetching document: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                
                self?.handleOrderUpdate(document, orderId: orderId)
            }

        listeners[orderId] = listener
        print("OrderRealtime: Subscribed to order \(orderId.prefix(8))")
    }

    func unsubscribeFromOrder(_ orderId: String) {
        guard let listener = listeners[orderId] else { return }
        listener.remove()
        listeners.removeValue(forKey: orderId)
        print("OrderRealtime: Unsubscribed from order \(orderId.prefix(8))")
    }

    /// Removes all active order listeners. Call on sign-out.
    func unsubscribeAll() {
        for (orderId, listener) in listeners {
            listener.remove()
            print("OrderRealtime: Unsubscribed from order \(orderId.prefix(8))")
        }
        listeners.removeAll()
    }

    // MARK: - Update Handling

    private func handleOrderUpdate(_ doc: DocumentSnapshot, orderId: String) {
        guard let data = doc.data(), let status = data["status"] as? String else { return }
        let handoffCode = data["handoff_code"] as? String

        print("OrderRealtime: Order \(orderId.prefix(8)) → status=\(status)")

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .orderStatusDidChange,
                object: nil,
                userInfo: [
                    "orderId":     orderId,
                    "newStatus":   status,
                    "handoffCode": handoffCode as Any
                ]
            )
        }
    }
}
