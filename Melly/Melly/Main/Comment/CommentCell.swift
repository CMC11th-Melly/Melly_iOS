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
           setSubViewUI()
        }
    }
    
    var vm: MemoryDetailViewModel? {
        didSet {
            bind()
        }
    }
    
    var height:CGFloat = 0
    var commentView = CommentView(frame: .zero).then {
        $0.backgroundColor = .clear
    }
    
    var subCommentView:[CommentView] = []
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        
        contentView.addSubview(commentView)
        commentView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(19)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        contentView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(commentView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(19)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(1)
        }
        
    }
    
    private func setSubViewUI() {
        if let comment = comment {
            commentView.comment = comment
            
            if !comment.children.isEmpty {
                
                for i in 0..<comment.children.count {
                    let commentSubView = CommentView()
                    commentSubView.comment = comment.children[i]
                    self.subCommentView.append(commentSubView)
                }
                
                for i in 0..<subCommentView.count {
                    contentView.addSubview(subCommentView[i])
                    if i == 0 {
                        subCommentView[i].snp.makeConstraints {
                            $0.top.equalTo(commentView.snp.bottom)
                            $0.leading.equalToSuperview().offset(75)
                            $0.trailing.equalToSuperview().offset(-39)
                        }
                    } else {
                        subCommentView[i].snp.makeConstraints {
                            $0.top.equalTo(subCommentView[i-1].snp.bottom).offset(10)
                            $0.leading.equalToSuperview().offset(75)
                            $0.trailing.equalToSuperview().offset(-39)
                        }
                    }
                    
                }
                
                separator.snp.remakeConstraints {
                    $0.top.equalTo(subCommentView[subCommentView.count-1].snp.bottom).offset(20)
                    $0.leading.equalToSuperview().offset(19)
                    $0.trailing.equalToSuperview().offset(-20)
                    $0.height.equalTo(1)
                }
                
                layoutIfNeeded()
                
            }
        }
    }
    
    private func bind() {
        if let vm = vm,
           let comment = comment {
            
            commentView.likeBT.rx.tap
                .map { comment }
                .bind(to: vm.input.likeButtonClicked)
                .disposed(by: disposeBag)
            
            commentView.editBT.rx.tap
                .map { comment}
                .bind(to: vm.input.commentEditObserver)
                .disposed(by: disposeBag)
            
            commentView.reCommentBT.rx.tap
                .map { (comment, comment.id) }
                .bind(to: vm.input.recommentObserver)
                .disposed(by: disposeBag)
            
            for i in 0..<subCommentView.count {
                
                subCommentView[i].likeBT.rx.tap
                    .map { comment.children[i] }
                    .bind(to: vm.input.likeButtonClicked)
                    .disposed(by: disposeBag)
                
                subCommentView[i].editBT.rx.tap
                    .map { comment.children[i]}
                    .bind(to: vm.input.commentEditObserver)
                    .disposed(by: disposeBag)
                
                subCommentView[i].reCommentBT.rx.tap
                    .map { (comment.children[i], comment.id) }
                    .bind(to: vm.input.recommentObserver)
                    .disposed(by: disposeBag)
                
                
            }
            
        }
    }
    
    
    
    
    
}

