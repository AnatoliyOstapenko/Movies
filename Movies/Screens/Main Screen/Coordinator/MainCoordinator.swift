//
//  MainCoordinator.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 26.01.2025.
//

import UIKit

protocol MainCoordinatorProtocol: Coordinator {
    func startDetail(with movie: Movie)
    func startFullScreenImage(with image: UIImage)
    func startTrailer(with trailerKey: String)
}

class MainCoordinator: MainCoordinatorProtocol {
    private let navController: UINavigationController
    private let apiService: APIServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    init(navController: UINavigationController, apiService: APIServiceProtocol, networkMonitor: NetworkMonitorProtocol) {
        self.navController = navController
        self.apiService = apiService
        self.networkMonitor = networkMonitor
    }
    
    func start() {
        let viewModel = MovieListViewModel(
            movieService: apiService,
            networkMonitor: networkMonitor
        )
        let movieListViewController = MovieListViewController(viewModel: viewModel)
        movieListViewController.coordinator = self
        navController.pushViewController(movieListViewController, animated: false)
    }

    func startDetail(with movie: Movie) {
        let detailViewModel = MovieDetailViewModel(movieService: apiService, movieId: movie.id)
        let movieDetailViewController = MovieDetailViewController(viewModel: detailViewModel, title: movie.title)
        movieDetailViewController.coordinator = self
        navController.pushViewController(movieDetailViewController, animated: true)
    }
    
    func startFullScreenImage(with image: UIImage) {
        let fullScreenVC = FullScreenImageViewController(image: image)
        fullScreenVC.modalPresentationStyle = .overFullScreen
        navController.present(fullScreenVC, animated: true)
    }
    
    func startTrailer(with trailerKey: String) {
        let trailerScreenVC = TrailerViewController(trailerKey: trailerKey)
        trailerScreenVC.modalPresentationStyle = .overFullScreen
        navController.present(trailerScreenVC, animated: true)
    }
}
