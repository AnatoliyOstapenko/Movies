//
//  APIEndpoint.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import Foundation

enum APIEndpoint {
    case popularMovies(page: Int)
    case movieDetails(movieId: Int)
    case searchMovies(query: String, page: Int)
    case movieTrailers(movieId: Int)
    case genres
    
    var url: String {
        switch self {
        case .popularMovies:
            return MovieAPIEndpoints.popularMoviesURL
        case .movieDetails(let movieId):
            return MovieAPIEndpoints.movieDetailsURL + "\(movieId)"
        case .searchMovies:
            return MovieAPIEndpoints.searchMoviesURL
        case .movieTrailers(let movieId):
            return MovieAPIEndpoints.movieTrailersURL + "\(movieId)/videos"
        case .genres:
            return MovieAPIEndpoints.genresURL
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
