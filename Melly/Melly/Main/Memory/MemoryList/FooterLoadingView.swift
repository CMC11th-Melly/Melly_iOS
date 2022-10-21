//
//  FooterLoadingView.swift
//  Melly
//
//  Created by Jun on 2022/10/20.
//

import UIKit

class FooterLoadingView: UICollectionReusableView {
    static let identifier = "FooterCell"
    
    let activityIndicator = UIActivityIndicatorView()
    
    func setupView() {
        backgroundColor = .clear
        activityIndicator.tintColor = .gray
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
}
