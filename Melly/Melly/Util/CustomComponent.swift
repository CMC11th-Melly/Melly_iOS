//
//  CustomComponent.swift
//  Melly
//
//  Created by Jun on 2022/09/14.
//

import Foundation
import UIKit
import Then

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(title: String) {
        self.init()
        self.setTitle(title, for: .normal)
        self.layer.cornerRadius = 12
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.backgroundColor = UIColor.gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CustomTetField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(title: String) {
        self.init()
        self.placeholder = title
        self.font = UIFont.systemFont(ofSize: 14)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.backgroundColor = .gray
        self.layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class BackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        self.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AlertLabel: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(_ label: String) {
        self.init(frame: .zero)
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle.fill"))
        self.backgroundColor = .gray
        self.layer.cornerRadius = 12
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        
        let label = UILabel().then {
            $0.text = label
            $0.font = UIFont.systemFont(ofSize: 16)
        }
        
        self.addSubview(label)
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(17)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
