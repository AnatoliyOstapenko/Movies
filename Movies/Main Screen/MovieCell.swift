//
//  MovieCell.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import UIKit
import SnapKit
import Kingfisher

class MovieCell: UITableViewCell {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        return view
    }()
    
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    private lazy var genreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = .lightGray
        return label
    }()
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .lightGray
        return label
    }()
    
    private let padding: CGFloat = 16
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .white
        contentView.addSubview(containerView)
        [posterImageView, titleLabel, genreLabel, ratingLabel].forEach { containerView.addSubview($0) }
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(padding)
        }
        
        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(posterImageView.snp.width).multipliedBy(1.43).priority(.high)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
        }
        
        genreLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        ratingLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        genreLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        ratingLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        genreLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-padding)
            make.leading.equalToSuperview().offset(padding)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.leading.equalTo(genreLabel.snp.trailing).offset(8)
        }
    }
    
    func configure(with movie: Movie) {
        if let path = movie.posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
            posterImageView.kf.setImage(with: url)
        } else {
            posterImageView.image = UIImage(systemName: "film")
        }
        titleLabel.text = movie.name
        genreLabel.text = movie.genreList
        ratingLabel.text = Localization.Detailed.rating(movie.vote)
    }
}
