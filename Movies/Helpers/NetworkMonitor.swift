//
//  NetworkMonitor.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 05.01.2025.
//

import UIKit
import Combine
import Network

protocol NetworkMonitorProtocol {
    var isConnected: AnyPublisher<Bool, Never> { get }
}

class NetworkMonitor: NetworkMonitorProtocol {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let _isConnected = CurrentValueSubject<Bool, Never>(true)
    public private(set) var isConnected: AnyPublisher<Bool, Never>

    private init() {
        isConnected = _isConnected.eraseToAnyPublisher()
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?._isConnected.send(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
