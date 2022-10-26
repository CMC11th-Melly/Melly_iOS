//
//  CommentHeaderView.swift
//  Melly
//
//  Created by Jun on 2022/10/26.
//

import UIKit
import Then

class CommentHeaderView: UICollectionReusableView {
    
    let imageView = UIImageView(image: UIImage(named: "memory_no_comment"))
    
    let titleView = UILabel().then {
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.text = "메모리에 첫 번째 댓글을 남겨주세요!"
    }
    
    func setupView() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.centerY.equalToSuperview()
        }
        
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(9)
            $0.centerY.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    
}
