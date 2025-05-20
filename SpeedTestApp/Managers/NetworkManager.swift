//
//  NetworkManager.swift
//  SpeedTestApp
//
//  Created by Adeel Sarwar on 20/05/2025.
//

import Foundation
import Network

class NetworkManager {
    static let shared = NetworkManager()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isConnected: Bool = false
    var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            self.isConnected = path.status == .satisfied
            self.connectionType = self.getConnectionType(from: path)

            // You can post notifications or call a delegate/closure here
            print("📶 Network status changed: \(self.isConnected ? "Connected" : "Disconnected"), Type: \(self.connectionType)")
        }

        monitor.start(queue: queue)
    }

    private func getConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
