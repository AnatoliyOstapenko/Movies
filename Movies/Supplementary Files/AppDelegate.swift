//
//  AppDelegate.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 03.01.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserSettings.token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlYzUyNWFhMDVkZDFjYWRhOWIyMDEzZDdlZGZmMTM2MyIsIm5iZiI6MTYzNDg1MzEwMy42MzYsInN1YiI6IjYxNzFlMGVmZDc1YmQ2MDA0MmUxMTRmYiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.i9qzI_9vguC3Qi5zWxDLTbz7oOrnwR-IeLiVv8sa-NY"
        NetworkMonitor.shared.startMonitoring()
        handleAppearance()
        return true
    }
    
    private func handleAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .black
    }
}

