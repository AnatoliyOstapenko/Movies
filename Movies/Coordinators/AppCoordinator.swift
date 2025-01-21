//
//  AppCoordinator.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 21.01.2025.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    func start()
    func childDidFinish(_ child: Coordinator?)
}

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let movieService = MovieAPIService()
        let viewModel = MovieListViewModel(movieService: movieService)
        let movieListViewController = MovieListViewController(viewModel: viewModel)
        movieListViewController.coordinator = self
        navigationController.pushViewController(movieListViewController, animated: false)
    }

    func startDetail(with movie: Movie) {
        let movieService = MovieAPIService()
        let detailViewModel = MovieDetailViewModel(movieService: movieService, movieId: movie.id)
        let movieDetailViewController = MovieDetailViewController(viewModel: detailViewModel, title: movie.title)
        movieDetailViewController.coordinator = self
        navigationController.pushViewController(movieDetailViewController, animated: true)
    }
    
    func startFullScreenImage(with image: UIImage) {
        let fullScreenVC = FullScreenImageViewController(image: image)
        fullScreenVC.modalPresentationStyle = .overFullScreen
        navigationController.present(fullScreenVC, animated: true)
    }
    
    func startTrailer(with trailerKey: String) {
        let trailerScreenVC = TrailerViewController(trailerKey: trailerKey)
        trailerScreenVC.modalPresentationStyle = .overFullScreen
        navigationController.present(trailerScreenVC, animated: true)
    }

    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
