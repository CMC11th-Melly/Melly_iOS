//
//  MemoryListCollectionViewCell.swift
//  Melly
//
//  Created by Jun on 2022/10/12.
//

import UIKit
import Then
import Kingfisher
import Foundation

class MemoryListCollectionViewCell: UICollectionViewCell {
    
    var memory:Memory? {
        didSet {
            if let memory = memory {
                configure(memory)
            }
        }
    }
    
    let imgView = UIImageView().then {
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
        $0.contentMode = .scaleAspectFill
    }
    
    let groupTitleLB = UILabel().then {
        $0.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 14)
        $0.clipsToBounds = true
        $0.textAlignment = .center
        $0.layer.cornerRadius = 6
    }
    
    let imageCountLB = UILabel().then {
        $0.text = "1"
        $0.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 16)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.textAlignment = .center
        $0.backgroundColor = UIColor(red: 0.122, green: 0.141, blue: 0.173, alpha: 0.7)
    }
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        $0.text = "오늘도 행복한 날!"
    }
    
    let dateLB = UILabel().then {
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
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
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        
        addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }
        
        imgView.addSubview(groupTitleLB)
        groupTitleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(25)
            $0.width.equalTo(45)
            $0.height.equalTo(24)
        }
        
        imgView.addSubview(imageCountLB)
        imageCountLB.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(4)
            $0.width.height.equalTo(38)
        }
        
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(imgView.snp.bottom).offset(19)
        }
        
        addSubview(dateLB)
        dateLB.snp.makeConstraints {
            $0.top.equalTo(imgView.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().offset(-18)
            $0.leading.greaterThanOrEqualTo(titleLB.snp.leading).offset(6)
        }
        
    }
    
    private func configure(_ memory: Memory) {
        if memory.memoryImages.count != 0 {
            let url = URL(string: memory.memoryImages[0].memoryImage)!
            imgView.kf.setImage(with: url)
            imageCountLB.text = "\(memory.memoryImages.count)"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let date = dateFormatter.date(from: memory.visitedDate)!
        dateFormatter.dateFormat = "MM월 dd일"
        dateLB.text = dateFormatter.string(from: date)
        titleLB.text = memory.title
        
        switch memory.groupType {
        case "FAMILY":
            groupTitleLB.text = "가족"
            groupTitleLB.backgroundColor = UIColor(red: 0.337, green: 0.29, blue: 0.898, alpha: 1)
        case "COMPANY":
            groupTitleLB.text = "동료"
            groupTitleLB.backgroundColor = UIColor(red: 0.278, green: 0.494, blue: 0.922, alpha: 1)
        case "COUPLE" :
            groupTitleLB.text = "연인"
            groupTitleLB.backgroundColor = UIColor(red: 0.941, green: 0.259, blue: 0.322, alpha: 1)
        case "FRIEND":
            groupTitleLB.text = "친구"
            groupTitleLB.backgroundColor = UIColor(red: 0.221, green: 0.679, blue: 0.459, alpha: 1)
        default:
            groupTitleLB.isHidden = true
        }
       
        
        
    }
    
    
    
}
