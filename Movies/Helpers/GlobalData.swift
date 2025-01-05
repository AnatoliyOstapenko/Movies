//
//  GlobalData.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 05.01.2025.
//

import Foundation

enum UserDefaultsKey: String {
    case movies = "movies"
}

@propertyWrapper struct UserDefaultsService<Value: Codable> {
    private let key: UserDefaultsKey
    private let defaultValue: Value
    private let storage: UserDefaults
    
    init(defaultValue: Value, key: UserDefaultsKey, storage: UserDefaults = .standard) {
        self.defaultValue = defaultValue
        self.key = key
        self.storage = storage
    }

    var wrappedValue: Value {
        get {
            guard let data = storage.data(forKey: key.rawValue) else {
                return defaultValue
            }
            let decoded = try? JSONDecoder().decode(Value.self, from: data)
            return decoded ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            storage.set(data, forKey: key.rawValue)
        }
    }
}

struct GlobalData {
    @UserDefaultsService<[Movie]>(defaultValue: [], key: .movies)
    static var movies
}



