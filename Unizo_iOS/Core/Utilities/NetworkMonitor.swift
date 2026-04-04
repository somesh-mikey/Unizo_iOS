//
//  NetworkMonitor.swift
//  Unizo_iOS
//
//  Monitors network connectivity using NWPathMonitor
//

import Network
import Foundation

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.unizo.networkmonitor")

    // Thread-safety note: `isConnected` is written on `queue` and read from main thread.
    // Bool is 1 byte — on ARM64, single-byte aligned reads/writes are naturally atomic.
    // Worst case is a stale read (benign TOCTOU), which is caught by requireNetwork().
    //
    // Starts as `false` to prevent a race condition where the first API call passes
    // the network guard before NWPathMonitor has fired its initial callback.
    private(set) var isConnected: Bool = false

    var onStatusChange: ((Bool) -> Void)?

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            self?.isConnected = connected
            self?.onStatusChange?(connected)
        }
        monitor.start(queue: queue)
    }

    func isReachable() -> Bool { return isConnected }

    /// Fires `onStatusChange` with the current `isConnected` value.
    /// Call this from SceneDelegate immediately after assigning `onStatusChange`
    /// to cover the case where NWPathMonitor's initial update fired before
    /// the closure was assigned (launch-time gap).
    func checkInitialState() {
        let currentState = isConnected
        onStatusChange?(currentState)
    }

    /// Convenience: assigns the status change handler and immediately checks initial state.
    func startObserving(_ handler: @escaping (Bool) -> Void) {
        onStatusChange = handler
        checkInitialState()
    }
}

enum NetworkError: LocalizedError {
    case noConnection

    var errorDescription: String? {
        return "No internet connection. Please check your network and try again.".localized
    }
}
