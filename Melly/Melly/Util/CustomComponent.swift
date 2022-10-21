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
    
    var title:String = ""
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                let attributedString = NSMutableAttributedString(string: title)
                attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 16)!, range: NSRange(location: 0, length: title.count))
                attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1), range: NSRange(location: 0, length: title.count))
                self.setAttributedTitle(attributedString, for: .normal)
                self.backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
            } else {
                let attributedString = NSMutableAttributedString(string: title)
                attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 16)!, range: NSRange(location: 0, length: title.count))
                attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1), range: NSRange(location: 0, length: title.count))
                self.setAttributedTitle(attributedString, for: .normal)
                self.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(title: String) {
        self.init()
        self.title = title
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 16)!, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1), range: NSRange(location: 0, length: title.count))
        self.setAttributedTitle(attributedString, for: .normal)
        self.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        
        self.layer.cornerRadius = 12
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CustomTextField: UITextField {
    
    override var isSecureTextEntry: Bool {
        didSet {
            if isSecureTextEntry {
                rightButton.setImage(UIImage(named: "open_eye"), for: .normal)
            } else {
                rightButton.setImage(UIImage(named: "close_eye"), for: .normal)
            }
        }
    }
    
    let rightButton = UIButton(type: .custom).then {
        $0.contentMode = .scaleAspectFit
        $0.setImage(UIImage(named: "open_eye"), for: .normal)
    }
    
    
    private let disposeBag = DisposeBag()
    
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
            
            wrapedView.addSubview(rightButton)
            rightButton.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
            rightView = wrapedView
            rightViewMode = .always
            
            
            rightButton.rx.tap.subscribe(onNext: {
                self.isSecureTextEntry.toggle()
            }).disposed(by: disposeBag)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.delegate = self
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        self.font = UIFont(name: "Pretendard-Regular", size: 16)
        self.textColor =  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
    }
    
}

extension CustomTextField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = UIColor(red: 0.274, green: 0.173, blue: 0.9, alpha: 1).cgColor
        textField.textColor =  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        return true
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
        $0.textColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 0.7)
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
    
    let textLB = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.text = "메모리를 쌓은 그룹을 선택해보세요"
    }

    let imgView = UIImageView(image: UIImage(named: "dropdown"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor

        addSubview(textLB)
        textLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(17)
        }

        addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.leading.greaterThanOrEqualTo(textLB.snp.trailing).offset(17)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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


final class UnderlineSegmentedControl: UISegmentedControl {
    private lazy var underlineView: UIView = {
        let width = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let height = 2.0
        let xPosition = CGFloat(self.selectedSegmentIndex * Int(width))
        let yPosition = self.bounds.size.height - 1.0
        let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor(red: 0.427, green: 0.459, blue: 0.506, alpha: 1)
        self.addSubview(view)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.removeBackgroundAndDivider()
    }
    override init(items: [Any]?) {
        super.init(items: items)
        self.removeBackgroundAndDivider()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func removeBackgroundAndDivider() {
        let image = UIImage()
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 0.427, green: 0.459, blue: 0.506, alpha: 1)], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 16)!], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 16)!], for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.underlineView.frame.origin.x = underlineFinalXPosition
            }
        )
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


class DatePickerButton: UIButton {
    
    let textLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ date: Date, isTime: Bool) {
        self.init()
        let dateFormatter = DateFormatter()
        if isTime {
            dateFormatter.locale = Locale(identifier: "ko_KO")
            dateFormatter.dateFormat = "yyyy. M. d (E)"
        } else {
            dateFormatter.locale = Locale(identifier: "en-US")
            dateFormatter.dateFormat = "hh:mm a"
        }
        textLB.text = dateFormatter.string(from: date)
    }
    
   private func setUI() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        
        addSubview(textLB)
        textLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(17)
        }
    }
    
    func changeDate(_ date: Date, isTime: Bool) {
        let dateFormatter = DateFormatter()
        if isTime {
            dateFormatter.locale = Locale(identifier: "ko_KO")
            dateFormatter.dateFormat = "yyyy. M. d (E)"
        } else {
            dateFormatter.locale = Locale(identifier: "en-US")
            dateFormatter.dateFormat = "hh:mm a"
        }
        textLB.text = dateFormatter.string(from: date)
    }
    
    
    
}
