//
//  NetworkMonitor.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 05.01.2025.
//

import Foundation
import Network

enum ConnectionType { case wifi, cellular, wiredEthernet, unknown }

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    public private(set) var isConnected = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    private init() {
        monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.start(queue: self.queue)
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isConnected = path.status != .unsatisfied
            self.updateConnectionType(path)
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wiredEthernet
        } else {
            connectionType = .unknown
        }
    }
}
