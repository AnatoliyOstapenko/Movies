//
//  MovieAPIClient.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import Foundation
import Alamofire
import Combine

protocol APIServiceProtocol {
    func fetchPopularMovies(page: Int) -> AnyPublisher<MovieResponse, APIError>
    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetail, APIError>
    func searchMovies(query: String, page: Int) -> AnyPublisher<MovieResponse, APIError>
    func fetchMovieTrailer(movieId: Int) -> AnyPublisher<MovieTrailerResponse,APIError>
    func fetchGenres() -> AnyPublisher<GenreResponse, APIError>
}

class MovieAPIClient: APIServiceProtocol {
    func fetchPopularMovies(page: Int = 1) -> AnyPublisher<MovieResponse, APIError> {
        return request(endpoint: .popularMovies(page: page))
    }
    
    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetail, APIError> {
        return request(endpoint: .movieDetails(movieId: movieId))
    }
    
    func searchMovies(query: String, page: Int = 1) -> AnyPublisher<MovieResponse, APIError> {
        return request(endpoint: .searchMovies(query: query, page: page))
    }
    
    func fetchMovieTrailer(movieId: Int) -> AnyPublisher<MovieTrailerResponse,APIError> {
        return request(endpoint: .movieTrailers(movieId: movieId))
    }
    
    func fetchGenres() -> AnyPublisher<GenreResponse, APIError> {
        return request(endpoint: .genres)
    }
}

extension MovieAPIClient {
    private func request<T: Decodable>(endpoint: APIEndpoint, method: HTTPMethod = .get) -> AnyPublisher<T, APIError> {
                
        guard !Environment.token.isEmpty else {
            return Fail(error: .invalidToken).eraseToAnyPublisher()
        }

        let headers = HTTPHeaders([
            .authorization(bearerToken: Environment.token)
        ])

        return AF.request(
            endpoint.url,
            method: method,
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

