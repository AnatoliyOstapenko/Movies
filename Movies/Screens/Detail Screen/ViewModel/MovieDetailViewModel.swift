//
//  MovieDetailViewModel.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 05.01.2025.
//

import Foundation
import Combine

class MovieDetailViewModel {
    @Published var movieDetails: MovieDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var movieTrailer: Trailer?
    
    private var movieId: Int
    private var movieService: MovieAPIService
    private var cancellables = Set<AnyCancellable>()
    
    init(movieService: MovieAPIService, movieId: Int) {
        self.movieService = movieService
        self.movieId = movieId
    }

    func loadDetails() {
        isLoading = true
        
        movieService.fetchMovieDetails(movieId: movieId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] detail in
                self?.movieDetails = detail
            }.store(in: &cancellables)
        
        movieService.fetchMovieTrailer(movieId: movieId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] trailerResponse in
                let trailer = trailerResponse.results.first(where: {$0.type == "Trailer"})
                self?.movieTrailer = trailer
            } .store(in: &cancellables)
    }
}

