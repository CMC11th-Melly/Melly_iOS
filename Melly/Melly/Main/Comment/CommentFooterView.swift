//
//  CommentFooterView.swift
//  Melly
//
//  Created by Jun on 2022/10/26.
//

import Foundation
import Then
import RxSwift
import RxCocoa


/**
 댓글 collection View footer
 > 댓글 수정 혹은 대댓글 작성시 사용
 */
class CommentFooterView: UICollectionReusableView {
    
    private let disposeBag = DisposeBag()
    
    static let identifier = "CommentFooter"
    var vm:MemoryDetailViewModel? {
        didSet {
            if let vm = vm {
                cancelBT.rx.tap
                    .bind(to: vm.input.reviseCancelObserver)
                    .disposed(by: disposeBag)
            }
        }
    }
    
    
    let titleView = UILabel().then {
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.text = "내 댓글 수정 중"
    }
    
    let cancelBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_x"), for: .normal)
    }
    
    func setupView() {
        backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.centerY.equalToSuperview()
        }
        
        addSubview(cancelBT)
        cancelBT.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-32)
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

