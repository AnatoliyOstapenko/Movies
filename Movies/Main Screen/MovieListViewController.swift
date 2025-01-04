//
//  MovieListViewController.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 03.01.2025.
//

import UIKit
import Combine
import SnapKit
import Kingfisher

class MovieListViewController: UIViewController {
    private lazy var navigationBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar()
        navBar.hasRightButton = true
        navBar.title = Localization.Main.mainTitle
        return navBar
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = Localization.Main.searching
        search.delegate = self
        return search
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(MovieCell.self, forCellReuseIdentifier: MovieCell.reuseId)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 220
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.showsVerticalScrollIndicator = false
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var viewModel: MovieListViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: MovieListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        [navigationBar, searchBar, tableView, tableView, activityIndicator].forEach{view.addSubview($0)}

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(53)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(4)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.tableView.reloadData()
                }
            }.store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(title: Localization.Errors.errorTitle, message: errorMessage)
            }.store(in: &cancellables)
        
        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)
        
        viewModel.loadMovies()
        
        navigationBar.rightButtonTap
            .sink { [weak self] _ in
                self?.showSortingOptions()
            }.store(in: &cancellables)
    }

    @objc private func refreshData(){
        viewModel.refresh()
    }
    
    private func showSortingOptions() {
        let alertController = UIAlertController(title: Localization.Main.sortBy, message: nil, preferredStyle: .actionSheet)
        
        let popularityAction = UIAlertAction(title: Localization.Main.popularity, style: .default) { [weak self] _ in
            self?.viewModel.handleSorting(.popularity)
        }
        let titleAction = UIAlertAction(title: Localization.Main.title, style: .default) { [weak self] _ in
            self?.viewModel.handleSorting(.title)
        }
        let releaseAction = UIAlertAction(title: Localization.Main.releaseDate, style: .default) { [weak self] _ in
            self?.viewModel.handleSorting(.releaseDate)
        }
        
        let cancelAction = UIAlertAction(title: Localization.Buttons.cancel, style: .cancel, handler: nil)
        [popularityAction, titleAction, releaseAction, cancelAction].forEach { alertController.addAction($0) }
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.Buttons.ok, style: .default))
        present(alert, animated: true)
    }
    
}

extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.reuseId, for: indexPath) as? MovieCell else {
            return UITableViewCell()
        }
        let movie = viewModel.movies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }
}

extension MovieListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedMovie = viewModel.movies[indexPath.row]
        viewModel.selectMovie(movie: selectedMovie)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            viewModel.loadMore()
        }
    }
}

extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.search(query: "")
    }
}
