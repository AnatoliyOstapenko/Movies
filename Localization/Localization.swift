//
//  Localization.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 03.01.2025.
//

import Foundation
import Localize_Swift

struct Localization {
    enum Errors {
        static var errorTitle: String { "errorTitle".localized() }
        static var offline: String { "offline".localized() }
        static func youtubeError(_ error: String) -> String { "youtubeError %@".localizedFormat(error) }
    }
    
    enum Main {
        static var mainTitle: String { "mainTitle".localized() }
        static var searching: String { "searching".localized() }
        static var sortBy: String { "sortBy".localized() }
        static var popularity: String { "popularity".localized() }
        static var title: String { "title".localized() }
        static var releaseDate: String { "releaseDate".localized() }
    }
    
    enum Buttons {
        static var cancel: String { "cancel".localized() }
        static var trailer: String { "trailer".localized() }
        static var close: String { "close".localized() }
        static var ok: String { "ok".localized() }
    }
    
    enum Detailed {
        static func rating(_ rate: String) -> String { "rating %@".localizedFormat(rate) }
        static var trailer: String { "trailer".localized() }
    }
}
