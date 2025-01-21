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
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        window?.overrideUserInterfaceStyle = .light
        let navController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navController)
        appCoordinator?.start()
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        appCoordinator = nil
    }
}

