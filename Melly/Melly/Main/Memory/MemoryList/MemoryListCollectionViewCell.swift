//
//  MemoryListCollectionViewCell.swift
//  Melly
//
//  Created by Jun on 2022/10/12.
//

import UIKit
import Then

class MemoryListCollectionViewCell: UICollectionViewCell {
    
    let goToMemoryBT = UIButton(type: .custom).then {
        $0.clipsToBounds = true
    }
    
    let imgView = UIImageView().then {
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
    }
    
    let groupTitleLB = UILabel().then {
        $0.text = "가족"
        $0.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 14)
        $0.layer.cornerRadius = 12
        $0.backgroundColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 0.4)
    }
    
    let imageCountLB = UILabel().then {
        $0.text = "1"
        $0.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 14)
        $0.layer.cornerRadius = 12
        $0.backgroundColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 0.4)
    }
    
    let titleView = UIView().then {
        $0.clipsToBounds = true
    }
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.427, green: 0.459, blue: 0.506, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "오늘도 행복한 날!"
    }
    
    let dateLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.text = "6월 14일"
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        clipsToBounds = true
        layer.cornerRadius = 12
        
        addSubview(goToMemoryBT)
        goToMemoryBT.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        goToMemoryBT.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }
        
        imgView.addSubview(groupTitleLB)
        groupTitleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(25)
        }
        
        
        
    }
    
}
