//
//  UITableViewCell + Ext.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import UIKit

extension UICollectionReusableView {
    static var reuseId: String { String(describing: Self.self) }
}

extension UITableViewCell {
    static var reuseId: String { String(describing: Self.self) }
}
