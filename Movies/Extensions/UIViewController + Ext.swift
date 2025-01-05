//
//  UIViewController + Ext.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 05.01.2025.
//

import UIKit
import SnapKit

// MARK: Empty State View
extension UIViewController {
    func showEmptyView(view: UIView, message: String) {
        if view.subviews.contains(where: { $0 is EmptyView }) {
            (view.subviews.first { $0 is EmptyView } as? EmptyView)?.configure(with: message)
            return
        }
        let emptyStateView = EmptyView()
        emptyStateView.configure(with: message)
        view.addSubview(emptyStateView)
        
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
        }
    }
    
    func hideEmptyView(view: UIView) {
        DispatchQueue.main.async {
            view.subviews.forEach { subview in
                if subview is EmptyView {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}

// MARK: Activity Indicator
extension UIViewController {
    func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func hideActivityIndicator() {
        if let activityIndicator = view.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}

// MARK: Alert
extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.Buttons.ok, style: .default))
        present(alert, animated: true)
    }
}

