//
//  String + Ext.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import Foundation

extension String {
    var toDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = dateFormatter.date(from: self) {
            return date
        }
        return Date()
    }
}
