//
//  MovieResponse.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
}

struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let genreIds: [Int]
    let voteAverage: Double
    let releaseDate: String
    // Internal
    var genreNames: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
}

extension Movie {
    var name: String {
        return "\(title), \(String(releaseDate.prefix(4)))"
    }
    var genreList: String {
        return genreNames?.compactMap {$0}.joined(separator: ", ") ?? "No rating"
    }
    var vote: String {
        return String(format:"%.1f", voteAverage)
    }
}

struct MovieDetail: Decodable {
    let title: String
    let overview: String
    let genres: [Genre]
    let releaseDate: String
    let backdropPath:String?
    let voteAverage: Double
    let productionCountries: [ProductionCountry]
    
    private enum CodingKeys: String, CodingKey {
        case title, overview, genres
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case productionCountries = "production_countries"
    }
}

extension MovieDetail {
    var countryYear: String {
        return "\(productionCountries.first?.name ?? ""), \(String(releaseDate.prefix(4)))"
    }
}

struct ProductionCountry: Decodable {
    let name:String
}

struct Genre: Decodable {
    let id: Int
    let name: String
}

struct MovieTrailerResponse: Decodable {
    let results: [Trailer]
}

struct Trailer: Decodable, Identifiable {
    let id: String
    let key: String
    let type: String
}

struct GenreResponse: Decodable {
    let genres: [Genre]
}

enum SortOption {
    case popularity
    case title
    case releaseDate
}
