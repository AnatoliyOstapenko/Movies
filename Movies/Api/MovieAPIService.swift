//
//  MovieAPIService.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import Foundation
import Alamofire
import Combine

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

class MovieAPIService {
    func fetchPopularMovies(page: Int = 1) -> AnyPublisher<MovieResponse, APIError> {
        return request(endpoint: .popularMovies(page: page))
    }
    
    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetail, APIError> {
        return request(endpoint: .movieDetails(movieId: movieId))
    }
    
    func searchMovies(query: String, page:Int = 1) -> AnyPublisher<MovieResponse, APIError> {
        return request(endpoint: .searchMovies(query: query, page: page))
    }
    
    func fetchMovieTrailer(movieId: Int) -> AnyPublisher<MovieTrailerResponse,APIError> {
        return request(endpoint: .movieTrailers(movieId: movieId))
    }
    
    func fetchGenres() -> AnyPublisher<GenreResponse, APIError> {
        return request(endpoint: .genres)
    }
}

extension MovieAPIService {
    private func request<T: Decodable>(endpoint: ApiService) -> AnyPublisher<T, APIError> {
                
        guard !Environment.token.isEmpty else {
            return Fail(error: .invalidToken).eraseToAnyPublisher()
        }

        let headers = HTTPHeaders([
            .authorization(bearerToken: Environment.token)
        ])

        return AF.request(
            endpoint.url,
            method: .get,
            parameters: endpoint.parameters,
            encoding: URLEncoding.default,
            headers: headers
        )
        .validate()
        .publishDecodable(type: T.self)
        .tryMap { response -> T in
            if let error = response.error {
                if let afError = error.asAFError {
                    if afError.isSessionTaskError,
                       let nsError = afError.underlyingError as? NSError,
                       nsError.code == NSURLErrorNotConnectedToInternet {
                        throw APIError.offline
                    }
                }
                throw APIError.requestFailed(error)
            }

            guard let value = response.value else {
                throw APIError.decodingError(response.error ?? AFError.responseValidationFailed(reason: .dataFileNil))
            }
            return value
        }
        .mapError { error -> APIError in
            if let apiError = error as? APIError {
                return apiError
            }
            return .unknown(error)
        }
        .eraseToAnyPublisher()
    }
}

