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
        $0.setImage(UIImage(named: "open_eye"), for: .normal)
    }
    
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
                $0.height.equalTo(56)
                $0.width.equalTo(45)
            }
            
            wrapedView.addSubview(rightButton)
            rightButton.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
            self.rightView = wrapedView
            self.rightViewMode = .always
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.delegate = self
        let paddingView = UIView()
        paddingView.snp.makeConstraints {
            $0.width.equalTo(21)
            $0.height.equalTo(56)
        }
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
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
    
    var comment:Comment
    
    lazy var profileImageView = UIImageView(image: UIImage(named: "profile")).then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 7.2
        if let image = comment.profileImage {
            let url = URL(string: image)!
            $0.kf.setImage(with: url)
        }
    }
    
    lazy var nameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1)
        if let text = comment.nickname {
            $0.text = text
        } else {
            $0.text = "삭제된 댓글"
        }
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
    }
    
    let editBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_dot"), for: .normal)
    }
    
    lazy var commentLB = UILabel().then {
        $0.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 13)
        $0.text = comment.content
        $0.numberOfLines = 0
    }
    
    lazy var dateLb = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        
        $0.font = UIFont(name: "Pretendard-Regular", size: 12)
        if let createdDate = comment.createdDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmm"
            let date = dateFormatter.date(from: createdDate) ?? Date()
            $0.text = date.timeAgoDisplay()
        } else {
            $0.text = ""
        }
        
    }
    
    let bottomView = UIView()
    
    let stOne = UIView().then {
        $0.backgroundColor = UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
    }
    
    lazy var likeBT = UIButton(type: .custom).then {
        let text = comment.likeCount == 0 ? "좋아요" : "좋아요 \(comment.likeCount)개"
        $0.setImage(UIImage(named: "memory_heart"), for: .normal)
        $0.setTitle(text, for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -9, bottom: 0, right: 0)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -9)
        
    }
    
    
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
    
    
    init(frame: CGRect, comment: Comment) {
        self.comment = comment
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        layer.cornerRadius = 8
        
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(36)
        }
        
        addSubview(nameLB)
        nameLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
        }
        
        addSubview(editBT)
        editBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview()
        }
        
        addSubview(commentLB)
        commentLB.snp.makeConstraints {
            $0.top.equalTo(nameLB.snp.bottom)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-52)
        }
        
        addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.top.equalTo(commentLB.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(26)
        }
        
        bottomView.addSubview(dateLb)
        dateLb.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.leading.equalTo(commentLB)
        }
        
        bottomView.addSubview(stOne)
        stOne.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalTo(dateLb.snp.trailing).offset(8)
            $0.width.equalTo(1)
            $0.height.equalTo(12)
        }
        
        bottomView.addSubview(likeBT)
        likeBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.leading.equalTo(stOne.snp.trailing).offset(4)
        }
        
        bottomView.addSubview(stTwo)
        stTwo.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalTo(likeBT.snp.trailing).offset(3.5)
            $0.width.equalTo(1)
            $0.height.equalTo(12)
        }
        
        
        bottomView.addSubview(reCommentBT)
        reCommentBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.leading.equalTo(stTwo.snp.trailing).offset(8)
        }
        
    }
    
    func getSize() -> CGFloat {
        var totalRect: CGFloat = 88.0
        commentLB.sizeToFit()
        totalRect += (commentLB.frame.width - 1.0)
        
        // 최종 계산 영역의 크기를 반환
        return totalRect
    }
    
    
    
    
}


class CommentTextField: UITextField {
    
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
        self.placeholder = title
        
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

extension CommentTextField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = UIColor(red: 0.274, green: 0.173, blue: 0.9, alpha: 1).cgColor
        textField.textColor =  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        return true
    }
    
}
