//
//  RecommandCollectionViewCell.swift
//  Melly
//
//  Created by Jun on 2022/09/26.
//

import UIKit
import RxSwift
import RxCocoa


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
    
    let bubbleView = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "main_bubble"), for: .normal)
    }
    
    let bubbleImageView = UIImageView().then {
        $0.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    let bubbleTitleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.text = "꽤 괜찮은 하루였다."
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    let bubbleContentLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
        $0.text = "오늘은 트러플에이커피에서 오빠랑 함께 놀았다. 그래 특히 기분이 더 좋았다. 역시 노는게 최고"
    }
    
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
            $0.leading.trailing.equalToSuperview()
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
            $0.leading.equalToSuperview()
        }
        
        addSubview(locationCategoryLB)
        locationCategoryLB.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(21)
            $0.leading.equalTo(locationLB.snp.trailing).offset(7)
        }
        
        addSubview(bubbleView)
        bubbleView.snp.makeConstraints {
            $0.top.equalTo(locationLB.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        bubbleView.addSubview(bubbleImageView)
        bubbleImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(19)
            $0.top.equalToSuperview().offset(30)
            $0.height.width.equalTo(50)
        }
        
        bubbleView.addSubview(bubbleTitleLB)
        bubbleTitleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.equalTo(bubbleImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-25)
        }
        
        bubbleView.addSubview(bubbleContentLB)
        bubbleContentLB.snp.makeConstraints {
            $0.top.equalTo(bubbleTitleLB.snp.bottom).offset(5)
            $0.leading.equalTo(bubbleImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-25)
        }
        
    }
    
    
}
