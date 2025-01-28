//
//  ApiService.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
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

enum ApiService {
    case popularMovies(page: Int)
    case movieDetails(movieId: Int)
    case searchMovies(query: String, page: Int)
    case movieTrailers(movieId: Int)
    case genres
    
    var url: String {
        switch self {
        case .popularMovies:
            return ApiMovie.popularMoviesURL
        case .movieDetails(let movieId):
            return ApiMovie.movieDetailsURL + "\(movieId)"
        case .searchMovies:
            return ApiMovie.searchMoviesURL
        case .movieTrailers(let movieId):
            return ApiMovie.movieTrailersURL + "\(movieId)/videos"
        case .genres:
            return ApiMovie.genresURL
        }
    }
    
    private var currentLanguage: String {
        Locale.preferredLanguages.first ?? "en-US"
    }
    
    var parameters: [String: Any] {
        let language = currentLanguage
        
        switch self {
        case .popularMovies(let page):
            return [
                "language": language,
                "page": page
            ]
        case .searchMovies(let query, let page):
            return [
                "language": language,
                "query": query,
                "page": page
            ]
        case .movieDetails, .movieTrailers, .genres:
            return ["language": language]
        }
    }
}
