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
    private(set) var isConnected: Bool = true

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
}

enum NetworkError: LocalizedError {
    case noConnection

    var errorDescription: String? {
        return "No internet connection. Please check your network and try again.".localized
    }
}
