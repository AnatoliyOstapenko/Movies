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
    var selectedSortOption: SortOption = .popularity
    var searchQuery = ""
    
    private var currentPage = 1
    private var isFetchingData = false
    private var allMovies: [Movie] = []
    private var sortOption = SortOption.popularity
    private var genres: [Genre] = []
    
    private let networkMonitor: NetworkMonitorProtocol
    private let movieService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
 
    init(movieService: APIServiceProtocol, networkMonitor: NetworkMonitorProtocol) {
        self.movieService = movieService
        self.networkMonitor = networkMonitor
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
        
        networkMonitor.isConnected
            .removeDuplicates()
            .sink { [weak self] isConected in
                if isConected {
                    self?.loadFromNetwork()
                } else {
                    self?.loadFromCache()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadFromNetwork() {
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
                self.handleResponse(movies: response.results)
            }
            .store(in: &cancellables)
    }
    
    private func handleResponse(movies: [Movie]) {
        let fetchedMovies = self.mapMovies(movies)
        allMovies.append(contentsOf: fetchedMovies)
        GlobalData.movies = self.allMovies
        handleSorting(self.selectedSortOption)
    }
    
    private func loadFromCache() {
        if !GlobalData.movies.isEmpty {
            allMovies = GlobalData.movies
            handleSorting(selectedSortOption)
            isLoading = false
            isFetchingData = false
            return
        }
        self.isLoading = false
        self.isFetchingData = false
        self.errorMessage = Localization.Errors.offline
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
    
    func search(query: String) {
        networkMonitor.isConnected
            .first()
            .sink { [weak self] isConnected in
                guard let self else { return }
                isConnected
                ? self.searchOnline(with: query)
                : self.searchingOffline(with: query)
            }
            .store(in: &cancellables)
    }
    
    private func searchOnline(with query: String) {
        self.searchQuery = query
        self.currentPage = 1
        self.allMovies = []
        self.movies = []
        loadMovies()
    }
    
    private func searchingOffline(with query: String) {
        if query.isEmpty {
            movies = GlobalData.movies
        } else {
            movies = allMovies.filter { movie in
                movie.title.contains(query)
            }
        }
    }
    
    func handleSorting(_ sortOption: SortOption) {
        isLoading = true
        defer { isLoading = false }

        let uniqueMovies = Array(Set(allMovies))
        var sortedMovies: [Movie] = []
        
        switch sortOption {
        case .popularity:
            sortedMovies = uniqueMovies.sorted(by: { $0.voteAverage > $1.voteAverage })
        case .title:
            sortedMovies = uniqueMovies.sorted {
                $0.title.compare($1.title, options: .caseInsensitive, locale: .current) == .orderedAscending
            }
        case .releaseDate:
            sortedMovies = uniqueMovies.sorted(by: {$0.releaseDate.toDate > $1.releaseDate.toDate})
        }
        movies = sortedMovies
    }
}
