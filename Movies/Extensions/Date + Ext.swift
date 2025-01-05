//
//  Date + Ext.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import Foundation

extension Date {
    var shortYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "uk_UA")
        let formattedDate = formatter.string(from: self)
        return formattedDate.capitalized
    }
}
