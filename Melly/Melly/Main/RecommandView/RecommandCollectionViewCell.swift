//
//  RecommandCollectionViewCell.swift
//  Melly
//
//  Created by Jun on 2022/09/26.
//

import UIKit

class RecommandCollectionViewCell: UICollectionViewCell {
    
    let mainImageView = UIImageView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        $0.isUserInteractionEnabled = true
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    let categoryView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
        $0.layer.cornerRadius = 6
    }
    
    let thumbsImage = UIImageView(image: UIImage(named: "thumbs"))
    
    let categoryLb = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.text = "연인과 추천"
    }
    
    let bookmarkBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "bookmark"), for: .normal)
    }
    
    let locationLB = UILabel().then {
        $0.text = "트러플에이커피 서울역점"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 18)
    }
    
    let locationCategoryLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.text = "카페, 디저트"
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let bubbleView = UIImageView(image: UIImage(named: "main_bubble"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        addSubview(mainImageView)
        mainImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(183)
        }
        
        categoryView.addSubview(thumbsImage)
        thumbsImage.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
        }
        
        categoryView.addSubview(categoryLb)
        categoryLb.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(thumbsImage.snp.trailing).offset(4)
        }
        
        mainImageView.addSubview(categoryView)
        categoryView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(18)
            $0.width.equalTo(98)
            $0.height.equalTo(24)
        }
        
        mainImageView.addSubview(bookmarkBT)
        bookmarkBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.trailing.equalToSuperview().offset(-18)
        }
        
        addSubview(locationLB)
        locationLB.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(30)
        }
        
        addSubview(locationCategoryLB)
        locationCategoryLB.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(21)
            $0.leading.equalTo(locationLB.snp.trailing).offset(7)
        }
        
        addSubview(bubbleView)
        bubbleView.snp.makeConstraints {
            $0.top.equalTo(locationLB.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(94)
        }
        
        
    }
    
}
