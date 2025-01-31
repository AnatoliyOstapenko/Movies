//
//  APIError.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 31.01.2025.
//

import Foundation

enum APIError: Error, LocalizedError {
    // For User
    case offline
    // For Debugging
    case invalidToken
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .offline:
            return Localization.Errors.offline
        case .invalidToken:
            return "Token is invalid. Please, check your token on https://api.themoviedb.org."
        case .requestFailed(let error):
            return "An request error occurred: \(error.localizedDescription)"
        case .decodingError(let error):
            return "An decoding error occurred: \(error.localizedDescription)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .invalidURL, .invalidResponse:
            return "Something went wrong, try again later"
        }
    }
}
