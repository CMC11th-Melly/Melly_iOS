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
    }
    
    let groupTitleLB = GroupTitleLB().then {
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
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.textAlignment = .center
        $0.backgroundColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 0.4)
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
        backgroundColor = .gray
        
        addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }
        
        imgView.addSubview(groupTitleLB)
        groupTitleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(25)
        }
        
        imgView.addSubview(imageCountLB)
        imageCountLB.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(4)
            $0.width.height.equalTo(38)
        }
        
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(imgView.snp.bottom).offset(16)
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
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: memory.visitedDate)!
        dateFormatter.dateFormat = "MM월 dd일"
        dateLB.text = dateFormatter.string(from: date)
        titleLB.text = memory.title
        
        if let groupName = memory.groupName {
            groupTitleLB.text = groupName
        } else {
            groupTitleLB.isHidden = true
        }
        
        
    }
    
    class GroupTitleLB: UILabel {
        private var padding = UIEdgeInsets(top: 6.0, left: 16.0, bottom: 6.0, right: 16.0)
        
        convenience init(padding: UIEdgeInsets) {
            self.init()
            self.padding = padding
        }
        
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: padding))
        }
        
        override var intrinsicContentSize: CGSize {
            var contentSize = super.intrinsicContentSize
            contentSize.height += padding.top + padding.bottom
            contentSize.width += padding.left + padding.right
            
            return contentSize
        }
    }
    
}
