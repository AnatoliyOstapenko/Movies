//
//  MovieDetailViewController.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 05.01.2025.
//

import UIKit
import Combine
import SnapKit
import Kingfisher

class MovieDetailViewController: UIViewController {
    private lazy var navigationBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar()
        navBar.hasLeftButton = true
        return navBar
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var countryYearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var genreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private lazy var trailerButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = Localization.Buttons.trailer
        configuration.baseBackgroundColor = .darkGray
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(trailerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let padding: CGFloat = 16
    private var viewModel: MovieDetailViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: MovieDetailViewModel, title: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationBar.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
        viewModel.loadDetails()
    }
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.backButtonTitle = ""
        [navigationBar, scrollView].forEach{view.addSubview($0)}
        scrollView.addSubview(contentView)
        [posterImageView, titleLabel, countryYearLabel,
         genreLabel, descriptionLabel, ratingLabel, trailerButton].forEach{contentView.addSubview($0)}
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(posterTapped))
        posterImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints(){
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(53)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view)
        }
        
        posterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        countryYearLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        genreLabel.snp.makeConstraints { make in
            make.top.equalTo(countryYearLabel.snp.bottom).offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        trailerButton.snp.makeConstraints { make in
            make.top.equalTo(genreLabel.snp.bottom).offset(padding)
            make.leading.equalToSuperview().inset(padding)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(trailerButton.snp.centerY)
            make.trailing.equalToSuperview().inset(padding)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(trailerButton.snp.bottom).offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.bottom.equalToSuperview().inset(padding)
        }
    }
    
    private func setupBindings(){
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showActivityIndicator()
                } else {
                    self?.hideActivityIndicator()
                }
            }.store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self else { return }
                self.showEmptyView(view: self.view, message: Localization.Empty.emptyMovie)
                self.showAlert(title: Localization.Errors.errorTitle, message: errorMessage)
            }.store(in: &cancellables)
        
        viewModel.$movieDetails
            .compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let self else { return }
                self.hideEmptyView(view: self.view)
                self.title = detail.title
                self.configure(detail: detail)
            }.store(in: &cancellables)
        
        viewModel.$movieTrailer
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] trailer in
                self?.trailerButton.isHidden = trailer == nil
            } .store(in: &cancellables)
    }
    private func configure(detail: MovieDetail) {
        if let path = detail.backdropPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500/\(path)")
            posterImageView.kf.setImage(with: url)
        } else {
            posterImageView.image = UIImage(systemName: "film")
        }
        titleLabel.text = detail.title
        countryYearLabel.text = detail.countryYear
        genreLabel.text = detail.genres.map{$0.name}.joined(separator: ", ")
        descriptionLabel.text = detail.overview
        ratingLabel.text = Localization.Detailed.rating(String(format:"%.1f", detail.voteAverage))
    }
    
    @objc func posterTapped(){
        guard let posterImage = posterImageView.image else { return }
        let fullScreenVC = FullScreenImageViewController(image: posterImage)
        fullScreenVC.modalPresentationStyle = .overFullScreen
        self.present(fullScreenVC, animated: true)
    }
    
    @objc private func trailerButtonTapped() {
        guard let trailerKey = viewModel.movieTrailer?.key else { return }
        
        let fullScreenVC = TrailerViewController(trailerKey: trailerKey)
        fullScreenVC.modalPresentationStyle = .overFullScreen
        self.present(fullScreenVC, animated: true)
    }
}

