//
//  SceneDelegate.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 03.01.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        
        let appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
        
        self.window = window
        window.makeKeyAndVisible()
        self.appCoordinator = appCoordinator
        
    }
}

