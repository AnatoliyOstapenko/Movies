//
//  AppCoordinator.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 21.01.2025.
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
}

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let navController = UINavigationController()
        let apiService = MovieAPIClient()
        let networkMonitor = NetworkMonitor.shared
        
        let mainCoordinator = MainCoordinator(
            navController: navController,
            apiService: apiService,
            networkMonitor: networkMonitor
        )
        
        mainCoordinator.start()
        childCoordinators = [mainCoordinator]
        window.rootViewController = navController
    }
}
