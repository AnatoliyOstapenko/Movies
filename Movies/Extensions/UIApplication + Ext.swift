//
//  UIApplication + Ext.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import UIKit

extension UIApplication {
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
    
    static func topNavigationController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first(where: { $0.isKeyWindow })?.rootViewController) -> UINavigationController? {
            
            if let nav = base as? UINavigationController {
                if let top = topNavigationController(base: nav.visibleViewController) {
                    return top
                }
                return nav
            }
            
            if let tab = base as? UITabBarController,
               let selected = tab.selectedViewController {
                return topNavigationController(base: selected)
            }
            
            if let presented = base?.presentedViewController {
                return topNavigationController(base: presented)
            }
            
            if let child = base?.children.first {
                return topNavigationController(base: child)
            }
            
            return base?.navigationController
        }
}
