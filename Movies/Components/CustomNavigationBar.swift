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
    // MARK: UI Components
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
    
    // MARK: Public Properties
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
    
    // MARK: Private
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Setup
    private func setupViews() {
        [backButton, titleLabel, rightButton].forEach{addSubview($0)}
        
        [titleLabel, backButton].forEach {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
    }
    
    private func setupConstraints() {
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
    
    // MARK: Actions
    @objc private func backButtonTapped() {
        guard let navController = UIApplication.topNavigationController() else { return }
        navController.popViewController(animated: true)
    }
    
    @objc private func rightButtonTapped() {
        rightButtonTap.send()
    }
}
