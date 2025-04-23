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
        table.delegate = self
        return table
    }()

    private let emptyView = EmptyView()
    private var dataSource: UITableViewDiffableDataSource<Int, Movie>!
    private var viewModel: MovieListViewModel
    private var cancellables: Set<AnyCancellable> = []
    weak var coordinator: MainCoordinatorProtocol?
    
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
        setupDataSource()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        [navigationBar, searchBar, tableView].forEach{view.addSubview($0)}
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        setupKeyboardToolbar()
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
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, Movie>(tableView: tableView) { (tableView, indexPath, movie) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.reuseId, for: indexPath) as? MovieCell else {
                return UITableViewCell()
            }
            cell.configure(with: movie)
            return cell
        }
    }
    
    private func updateSnapshot(movies: [Movie]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies, toSection: 0)
        
        if movies.isEmpty {
            self.showEmptyView(
                view: view,
                message: viewModel.searchQuery.isEmpty ?
                Localization.Empty.emptyMovies : Localization.Empty.emptySearchResult
            )
        } else {
            self.hideEmptyView(view: view)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showActivityIndicator()
                } else {
                    self?.hideActivityIndicator()
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }.store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self else { return }
                self.showEmptyView(view: view, message: Localization.Empty.emptyMovies)
                self.showAlert(title: Localization.Errors.errorTitle, message: errorMessage)
            }.store(in: &cancellables)
        
        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] movies in
                guard let self else { return }
                self.updateSnapshot(movies: movies)
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
    
    @objc private func handleTap() {
        searchBar.resignFirstResponder()
    }
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(handleTap))
        doneButton.image = UIImage(systemName: "keyboard.chevron.compact.down")
        doneButton.tintColor = .black
        toolbar.items = [flexibleSpace, doneButton, flexibleSpace]
        searchBar.inputAccessoryView = toolbar
    }
    
    private func showSortingOptions() {
        let alertController = UIAlertController(title: Localization.Main.sortBy, message: nil, preferredStyle: .actionSheet)
        
        func createAction(for option: SortOption, title: String) -> UIAlertAction {
            let isSelected = (option == viewModel.selectedSortOption)
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.viewModel.selectedSortOption = option
                self?.viewModel.handleSorting(option)
            }
            if isSelected {
                action.setValue(true, forKey: "checked")
            }
            return action
        }
        let popularityAction = createAction(for: .popularity, title: Localization.Main.popularity)
        let titleAction = createAction(for: .title, title: Localization.Main.title)
        let releaseAction = createAction(for: .releaseDate, title: Localization.Main.releaseDate)
        let cancelAction = UIAlertAction(title: Localization.Buttons.cancel, style: .cancel, handler: nil)
        
        [popularityAction, titleAction, releaseAction, cancelAction].forEach { alertController.addAction($0) }
        
        present(alertController, animated: true, completion: nil)
    }
}

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let movie = dataSource.itemIdentifier(for: indexPath),
              let coordinator else { return }
        coordinator.startDetail(with: movie)
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
