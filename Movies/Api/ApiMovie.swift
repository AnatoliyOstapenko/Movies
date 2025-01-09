//
//  ApiMovie.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import Foundation

struct WebUrl {
    static let prodUrl = Environment.baseUrl
}

public struct ApiMovie {
    static var baseURL: String {
        return WebUrl.prodUrl
    }
    
    static var popularMoviesURL: String {
        return baseURL + "/movie/popular"
    }
    
    static var movieDetailsURL: String {
        return baseURL + "/movie/"
    }
    
    static var searchMoviesURL: String {
        return baseURL + "/search/movie"
    }
    
    static var movieTrailersURL:String{
        return baseURL + "/movie/"
    }
    
    static var genresURL:String{
        return baseURL + "/genre/movie/list"
    }
}
