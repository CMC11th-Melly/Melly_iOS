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
import Kingfisher

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

class CustomTextField: UIView {
    
    private let disposeBag = DisposeBag()
    
    var isSecure:Bool = false {
        didSet {
            if isSecure {
                rightButton.setImage(UIImage(named: "open_eye"), for: .normal)
                textField.isSecureTextEntry = true
            } else {
                rightButton.setImage(UIImage(named: "close_eye"), for: .normal)
                textField.isSecureTextEntry = false
            }
        }
    }
    
    lazy var textField = UITextField().then {
        $0.delegate = self
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.textColor =  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
    }
    
    
    let rightButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "open_eye"), for: .normal)
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        bind()
    }
    
    convenience init(title: String, isSecure: Bool = false) {
        self.init()
        textField.placeholder = title
        
        if isSecure {
            textField.isSecureTextEntry = true
            rightButton.isHidden = false
            self.isSecure = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        
        addSubview(rightButton)
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-22)
            $0.height.width.equalTo(24)
            $0.centerY.equalToSuperview()
        }
        
        addSubview(textField)
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(rightButton.snp.leading).offset(-5)
            $0.height.equalTo(19)
        }
        
        
        
        
    }
    
    private func bind() {
        
        rightButton.rx.tap
            .subscribe(onNext: {
                self.isSecure.toggle()
            }).disposed(by: disposeBag)
        
    }
    
    
    
}

extension CustomTextField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        layer.borderColor = UIColor(red: 0.274, green: 0.173, blue: 0.9, alpha: 1).cgColor
        textField.textColor =  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        textField.textColor =  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
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
    
    let imageView = UIImageView(image: UIImage(named: "research_check"))
    
    let label = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 15)
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
        label.text = text
    }
    
    private func setUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(24)
        }
        
        addSubview(label)
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(12)
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
        view.backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
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
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 18)!], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 18)!], for: .normal)
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


class DynamicHeightCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}


class CommentView: UIView {
    
    var comment:Comment? {
        didSet {
            setData()
        }
    }
    
    var height:CGFloat = 65
    
    func setData() {
        if let comment = comment {
            if let image = comment.profileImage {
                let url = URL(string: image)!
                profileImageView.kf.setImage(with: url)
            }
            if let text = comment.nickname {
                nameLB.text = text
            } else {
                nameLB.text = "삭제된 댓글"
            }
            
            commentLB.text = comment.content
            
            height += commentLB.frame.height
            
            if comment.loginUserLike {
                likeBT.heartImageView.image = UIImage(named: "comment_heart_fill")
                likeBT.titleLB.textColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
            }
            
            likeBT.titleLB.text = comment.likeCount == 0 ? "좋아요" : "좋아요 \(comment.likeCount)개"
            
            
            if let createdDate = comment.createdDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmm"
                let date = dateFormatter.date(from: createdDate) ?? Date()
                dateLb.text = date.timeAgoDisplay()
            } else {
                dateLb.text = ""
            }
        }
    }
    
    let profileImageView = UIImageView(image: UIImage(named: "profile")).then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 7.2
        $0.contentMode = .scaleAspectFill
        
    }
    
    let nameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
    }
    
    let editBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "comment_edit"), for: .normal)
    }
    
    let commentLB = UILabel().then {
        $0.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 13)
        $0.numberOfLines = 0
    }
    
    let bottomView = UIView()
    
    let dateLb = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 12)
        
    }
    
    let stOne = UIView().then {
        $0.backgroundColor = UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
    }
    
    let likeBT = LikeButton()
    
    
    let stTwo = UIView().then {
        $0.backgroundColor = UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
    }
    
    let reCommentBT = UIButton(type: .custom).then {
        let string = "답글달기"
        let attributedString = NSMutableAttributedString(string: string)
        let font =  UIFont(name: "Pretendard-Regular", size: 12)!
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setUI() {
        layer.cornerRadius = 8
        backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(11)
            $0.width.height.equalTo(36)
        }
        
        addSubview(nameLB)
        nameLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(15)
            $0.height.equalTo(22)
        }
        
        addSubview(editBT)
        editBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.height.equalTo(14)
        }
        
        addSubview(commentLB)
        commentLB.snp.makeConstraints {
            $0.top.equalTo(nameLB.snp.bottom)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(editBT.snp.leading).offset(-4)
        }
        
        addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.top.equalTo(commentLB.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(commentLB)
            $0.height.equalTo(19)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        bottomView.addSubview(dateLb)
        dateLb.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(4)
            $0.height.equalTo(19)
        }
        
        bottomView.addSubview(stOne)
        stOne.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(dateLb.snp.trailing).offset(8)
            $0.width.equalTo(1)
            $0.height.equalTo(12)
        }
        
        bottomView.addSubview(likeBT)
        likeBT.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(stOne.snp.trailing).offset(4)
            $0.width.equalTo(72.5)
            $0.height.equalTo(19)
        }
        
//        bottomView.addSubview(stTwo)
//        stTwo.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.leading.equalTo(likeBT.snp.trailing).offset(4)
//            $0.width.equalTo(1)
//            $0.height.equalTo(12)
//        }
//
//
//        bottomView.addSubview(reCommentBT)
//        reCommentBT.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.leading.equalTo(stTwo.snp.trailing).offset(8)
//            $0.height.equalTo(19)
//        }
        
    }
    
    
    
    
    
}


class CommentTextField: UIView {
    
    lazy var textField = UITextField().then {
        
        $0.delegate = self
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.textColor =  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
    }
    
    let rightButton = UIButton(type: .custom).then {
        let string = "등록"
        let attributedString = NSMutableAttributedString(string: string)
        let font = UIFont(name: "Pretendard-SemiBold", size: 16)!
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    convenience init(title: String) {
        self.init()
        textField.placeholder = title
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        
        addSubview(rightButton)
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(26)
            $0.width.equalTo(40)
        }
        
        addSubview(textField)
        textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalTo(rightButton.snp.leading)
            $0.height.equalTo(26)
        }
       
    }
    
}

extension CommentTextField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        layer.borderColor = UIColor(red: 0.274, green: 0.173, blue: 0.9, alpha: 1).cgColor
        textField.textColor =  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
    }
    
    
    
}


class RightAlert: UIView {
    
    let imageView = UIImageView(image: UIImage(named: "ok"))
    let labelView = UILabel().then {
        $0.textColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 0.7)
        self.layer.cornerRadius = 12
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(23)
            $0.width.height.equalTo(24)
        }
        
        self.addSubview(labelView)
        labelView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class CategoryPicker: UIButton {
    
    var mode:Bool = false {
        didSet {
            if mode {
                textLabel.textColor = .white
                backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
                imgView.image = UIImage(named: "memory_x")
            } else {
                textLabel.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
                backgroundColor = .white
                imgView.image = UIImage(named: "memory_filter")
            }
        }
    }
    
    let textLabel = UILabel().then {
        $0.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
        $0.text = "카테고리"
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let imgView = UIImageView(image: UIImage(named: "memory_filter"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String) {
        self.init()
        textLabel.text = title
    }
    
    
    private func setUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 1.2
        layer.borderColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1).cgColor
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }
        
        addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(textLabel.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
    }
    
}


class DefaultButton:UIButton {
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.173, green: 0.092, blue: 0.671, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(_ title: String, _ mode: Bool) {
        self.init()
        
        
        
        self.titleLB.text = title
        self.layer.cornerRadius = 12
        
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
        
        if mode {
            titleLB.textColor = .white
            backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        } else {
            titleLB.textColor = UIColor(red: 0.173, green: 0.092, blue: 0.671, alpha: 1)
            backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.984, alpha: 1)
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class LikeButton: UIButton {
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 12)
        $0.textAlignment = .left
    }
    
    let heartImageView = UIImageView(image: UIImage(named: "comment_heart"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(heartImageView)
        heartImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(4)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(9.62)
            $0.width.equalTo(10.5)
        }
        
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.leading.equalTo(heartImageView.snp.trailing).offset(3)
            $0.trailing.equalToSuperview().offset(-4)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
