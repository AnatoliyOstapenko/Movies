//
//  CustomNavigationBar.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 04.01.2025.
//

import UIKit
import SnapKit
import Combine

final class CustomNavigationBar: UIView {
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.isHidden = true
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "text.badge.checkmark"), for: .normal)
        button.tintColor = .black
        button.isHidden = true
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var title: String = String() {
        didSet { titleLabel.text = title }
    }
    
    var hasLeftButton: Bool = false {
        didSet {
            backButton.isHidden = !hasLeftButton
        }
    }
    
    var hasRightButton: Bool = false {
        didSet {
            rightButton.isHidden = !hasRightButton
        }
    }

    let rightButtonTap = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [backButton, titleLabel, rightButton].forEach{addSubview($0)}
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        backButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(8)
        }
        
        rightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }

    private func configure(with title: String, showBackButton: Bool, rightButtonImage: UIImage?) {
        titleLabel.text = title
        backButton.isHidden = !showBackButton
        
        if let image = rightButtonImage {
            rightButton.setImage(image, for: .normal)
            rightButton.isHidden = false
        }
    }

    @objc private func backButtonTapped() {
        guard let navController = UIApplication.topNavController() else { return }
        navController.popViewController(animated: true)
    }
    
    @objc private func rightButtonTapped() {
        rightButtonTap.send()
    }
}
