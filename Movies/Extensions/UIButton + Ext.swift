//
//  UIButton + Ext.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 26.01.2025.
//

import UIKit

extension UIButton {
    static func makeFilledButton(title: String, target: Any?, action: Selector) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = .darkGray
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: 10,
            bottom: 5,
            trailing: 10
        )
        let button = UIButton(configuration: configuration)
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
}
