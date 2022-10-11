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
            $0.width.height.equalTo(22)
        }
        
        self.addSubview(labelView)
        labelView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(17)
            $0.trailing.equalToSuperview().offset(-24)
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

class TermsNAgreeView: UIView {
    
    let subOneBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "disagree_terms"), for: .normal)
    }
    
    let subOneLB = UILabel().then {
        $0.text = "이용약관 (필수)"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let subOneSlideBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "close_terms"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ text: String) {
        self.init()
        subOneLB.text = text
        
    }
    
    private func setUI() {
        addSubview(subOneBT)
        addSubview(subOneLB)
        addSubview(subOneSlideBT)
        
        subOneBT.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        subOneLB.snp.makeConstraints {
            $0.leading.equalTo(subOneBT.snp.trailing).offset(15)
            $0.centerY.equalToSuperview()
        }
        
        subOneSlideBT.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}


class MainTextField: UITextField {
    
    
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 51, height: 44))
    let bt = UIButton(frame: CGRect(x:15.92, y: 0, width: 18.4, height: 44))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        self.font = UIFont(name: "Pretendard-Regular", size: 14)
        self.placeholder = "장소, 메모리, 그룹, 키워드 검색"
        self.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        
        bt.setImage(UIImage(named: "hamburger"), for: .normal)
        bt.imageView?.contentMode = .scaleAspectFit
        paddingView.addSubview(bt)
        
        self.leftView = paddingView
        self.leftViewMode = .always
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
    }
    
}


class GroupToggleButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        self.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        self.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        self.layer.cornerRadius = 12
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ text: String) {
        self.init()
        self.setTitle(text, for: .normal)
        self.setTitle(text, for: .selected)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.titleLabel?.textColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
                self.backgroundColor = UIColor(red: 0.427, green: 0.459, blue: 0.506, alpha: 1)
                
            } else {
                self.titleLabel?.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
                self.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
            }
        }
    }
    
    
    
    
}

class ResearchComponent: UIView {
    
    let imageView = UIImageView()
    
    let label = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 15)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ text: String, _ image: String) {
        self.init()
        imageView.image = UIImage(named: image)
        label.text = text
    }
    
    private func setUI() {
        backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
        layer.cornerRadius = 12
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(25)
            $0.width.height.equalTo(26)
        }
        
        addSubview(label)
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(15)
        }
    }
    
}
