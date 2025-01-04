//
//  UIApplication + Ext.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import UIKit

extension UIApplication {
    static func topNavController(base: UIViewController? = nil) -> UINavigationController? {
        let windowScene = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first as? UIWindowScene

        let rootVC = base ?? windowScene?.windows.first?.rootViewController
        
        guard let base = rootVC else {
            return nil
        }
        if let nav = base as? UINavigationController {
            return nav
        }
        if let nav = base.navigationController {
            return nav
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topNavController(base: selected)
         }
         if let presented = base.presentedViewController {
             return topNavController(base: presented)
        }
        if let child = base.children.first {
            return topNavController(base: child)
        }
        return base.navigationController
    }

    static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        if let child = base?.children.first {
            return topViewController(base: child)
        }
        return base
    }
}
