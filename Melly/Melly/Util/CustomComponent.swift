//
//  CustomComponent.swift
//  Melly
//
//  Created by Jun on 2022/09/14.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(title: String) {
        self.init()
        self.setTitle(title, for: .normal)
        self.layer.cornerRadius = 12
        self.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        self.titleLabel?.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        self.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CustomTextField: UITextField {
    
    enum CurrentPasswordInputStatus {
        case invalidPassword
        case validPassword
    }
    
    private let disposeBag = DisposeBag()
    private var currentPasswordInputStatus: CurrentPasswordInputStatus = .invalidPassword
    let textResetEvent = PublishSubject<Void>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    convenience init(title: String, isSecure: Bool = false) {
        self.init()
        self.placeholder = title
        if isSecure {
            self.isSecureTextEntry = true
            let wrapedView = UIView()
            wrapedView.snp.makeConstraints {
                $0.height.equalTo(self.frame.height)
                $0.width.equalTo(45)
            }
            let rightButton = UIButton()
            rightButton.contentMode = .scaleAspectFit
            rightButton.setImage(UIImage(named: "open_eye"), for: .normal)
            wrapedView.addSubview(rightButton)
            rightButton.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
            rightView = wrapedView
            rightViewMode = .always
            
            rightButton.rx.tap.asDriver { _ in .never() }
                .drive(onNext: { [weak self] in
                    self?.updateCurrentStatus(rightButton)
                }).disposed(by: disposeBag)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateCurrentStatus(_ bt: UIButton) {
        isSecureTextEntry.toggle()
        if isSecureTextEntry {
            bt.setImage(UIImage(named: "open_eye"), for: .normal)
        } else {
            bt.setImage(UIImage(named: "close_eye"), for: .normal)
        }
    }
    
    private func setupViews() {
        self.font = UIFont(name: "Pretendard-Regular", size: 14)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.backgroundColor = .gray
        self.layer.cornerRadius = 12
    }
    
}



class BackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        self.setImage(UIImage(named: "back"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AlertLabel: UIView {
    
    let imageView = UIImageView(image: UIImage(named: "alert"))
    let labelView = UILabel().then {
        $0.text = ""
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray
        self.layer.cornerRadius = 12
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        
        self.addSubview(labelView)
        labelView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(17)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class DropMenuButton: UIButton {
    
    let labelView = UILabel().then {
        $0.text = ""
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
    }
    
    let imgView = UIImageView(image: UIImage(named: "dropdown"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        self.layer.borderColor = CGColor(red: 226/255, green: 229/255, blue: 233/255, alpha: 1)
        self.layer.borderWidth = 1
        
        addSubview(labelView)
        labelView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(22)
        }
        
        addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-31)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ text: String) {
        self.init()
        labelView.text = text
        
    }
    
}
