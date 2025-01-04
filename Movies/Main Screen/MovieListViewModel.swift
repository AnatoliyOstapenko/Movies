//
//  MovieListViewModel.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import Foundation
import Combine
import UIKit

class MovieListViewModel {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var currentPage = 1
    private var isFetchingData = false
    private var searchQuery = ""
    private var allMovies: [Movie] = []
    private var sortOption = SortOption.popularity
    private var genres: [Genre] = []
    
    private var movieService: MovieAPIService
    private var cancellables = Set<AnyCancellable>()
    
    init(movieService: MovieAPIService) {
        self.movieService = movieService
        loadGenres()
    }
    
    func refresh(){
        currentPage = 1
        allMovies = []
        movies = []
        loadMovies()
    }
    
    func loadMovies() {
        guard !isFetchingData else { return }

        isLoading = true
        isFetchingData = true

        let publisher = searchQuery.isEmpty
            ? movieService.fetchPopularMovies(page: currentPage)
            : movieService.searchMovies(query: searchQuery, page: currentPage)

        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                self.isFetchingData = false

                if case .failure(let error) = completion {
                    self.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.allMovies.append(contentsOf: self.mapMovies(response.results))
                self.handleSorting(.popularity)
            }
            .store(in: &cancellables)
    }

    
    private func mapMovies(_ movies: [Movie]) -> [Movie] {
        movies.map { movie in
            let genreNames = movie.genreIds.compactMap { id in
                genres.first(where: { $0.id == id })?.name
            }

            return Movie(
                id: movie.id,
                title: movie.title,
                posterPath: movie.posterPath,
                genreIds: movie.genreIds,
                voteAverage: movie.voteAverage,
                releaseDate: movie.releaseDate,
                genreNames: genreNames
            )
        }
    }

    
    private func loadGenres() {
        isLoading = true
        movieService.fetchGenres()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] response in
                self?.genres = response.genres
            }.store(in: &cancellables)
    }
    
    func loadMore() {
        if !isFetchingData {
            currentPage += 1
            loadMovies()
        }
    }
    
    func search(query:String) {
        self.searchQuery = query
        self.currentPage = 1
        self.allMovies = []
        self.movies = []
        loadMovies()
    }

    func handleSorting(_ sortOption: SortOption) {
        isLoading = true
        defer { isLoading = false }
        
        var sortedMovies = allMovies
        switch sortOption {
        case .popularity:
            sortedMovies = allMovies.sorted(by: { $0.voteAverage > $1.voteAverage})
        case .title:
            sortedMovies = allMovies.sorted {
                $0.title.compare($1.title, options: .caseInsensitive, locale: .current) == .orderedAscending
            }
        case .releaseDate:
            sortedMovies = allMovies.sorted(by: {$0.releaseDate.toDate > $1.releaseDate.toDate})
        }
        movies = sortedMovies
    }
    
    func selectMovie(movie: Movie) {}
}

