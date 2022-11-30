//
//  CommentCell.swift
//  Melly
//
//  Created by Jun on 2022/10/25.
//

import UIKit
import Then
import Kingfisher
import Foundation
import RxCocoa
import RxSwift


/// 댓글 collection View Cell
class CommentCell: UICollectionViewCell {
    
    private let disposeBag = DisposeBag()
    
    var comment: Comment? {
        didSet {
            commentView.comment = comment
        }
    }
    
    var vm: MemoryDetailViewModel? {
        didSet {
            bind()
        }
    }
    
    var height:CGFloat = 0
    
    var commentView = CommentView(frame: .zero)
    
    var subCommentView:[CommentView] = []
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        contentView.addSubview(commentView)
        commentView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(19)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        
    }
    
    private func bind() {
        if let vm = vm {
            
            commentView.likeBT.rx.tap
                .map { self.comment }
                .bind(to: vm.input.likeButtonClicked)
                .disposed(by: disposeBag)
            
            commentView.editBT.rx.tap
                .map { self.comment!}
                .bind(to: vm.input.commentEditObserver)
                .disposed(by: disposeBag)
            
            
            
        }
    }
    
    
    
}

