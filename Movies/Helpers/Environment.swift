//
//  Environment.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 09.01.2025.
//

import Foundation

public enum Environment {
    enum Keys {
        static let token = "API_TOKEN"
        static let baseUrl = "BASE_URL"
    }

    // Accessing Info.plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    // Fetching `baseUrl` from Info.plist
    static let baseUrl: String = {
        guard let baseUrlString = Environment.infoDictionary[Keys.baseUrl] as? String else {
            fatalError("Failed to get Base URL from plist")
        }
        return baseUrlString
    }()

    // Fetching `token` from Info.plist
    static let token: String = {
        guard let apiKeyString = Environment.infoDictionary[Keys.token] as? String else {
            fatalError("Failed to get API token from plist")
        }
        return apiKeyString
    }()
}
