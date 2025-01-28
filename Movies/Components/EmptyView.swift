//
//  EmptyView.swift
//  Movies
//
//  Created by Anatoliy Ostapenko on 05.01.2025.
//

import UIKit
import SnapKit

class EmptyView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        label.text = text
    }

    private func setupViews() {
       addSubview(label)
    }
    
    private func setupConstraints(){
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
