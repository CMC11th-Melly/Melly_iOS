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

class CommentCell: UICollectionViewCell {
    
    static func fittingSize(_ comment: Comment, availableWidth: CGFloat) -> CGSize {
        let cell = CommentCell()
        cell.comment = comment
        let targetSize = CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height)
        print("target Size", targetSize)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .required)
    }
    
    var comment: Comment? {
        didSet {
            commentView.comment = comment
            height += commentView.height
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
        
//        contentView.addSubview(separator)
        
        
        
        //            for i in 0..<comment.children.count {
        //
        //                let commentsubView = CommentView(frame: .zero, comment: comment.children[i])
        //                let view = UIView().then {
        //                    $0.backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        //                    $0.layer.cornerRadius = 8
        //                }
        //
        //                addSubview(view)
        //
        //
        //                subCommentView.append(commentsubView)
        //
        //                if i == 0 {
        //                    view.snp.makeConstraints {
        //                        $0.top.equalTo(commentView.snp.bottom)
        //                        $0.leading.equalToSuperview().offset(75)
        //                        $0.trailing.equalToSuperview().offset(-39)
        //                        $0.height.equalTo(commentView.getSize() + 10.0)
        //                    }
        //
        //                    view.addSubview(commentsubView)
        //                    commentsubView.snp.makeConstraints {
        //                        $0.top.equalToSuperview().offset(2)
        //                        $0.leading.equalToSuperview().offset(11)
        //                        $0.trailing.equalToSuperview().offset(-10)
        //                        $0.height.equalTo(commentView.getSize())
        //                    }
        //                } else {
        //
        //                    view.snp.makeConstraints {
        //                        $0.top.equalTo(subCommentView[i-1].snp.bottom).offset(10)
        //                        $0.leading.equalToSuperview().offset(75)
        //                        $0.trailing.equalToSuperview().offset(-39)
        //                        $0.height.equalTo(commentView.getSize() + 10.0)
        //                    }
        //
        //                    view.addSubview(commentsubView)
        //                    commentsubView.snp.makeConstraints {
        //                        $0.top.equalToSuperview().offset(2)
        //                        $0.leading.equalToSuperview().offset(11)
        //                        $0.trailing.equalToSuperview().offset(-10)
        //                        $0.height.equalTo(commentView.getSize())
        //                    }
        //
        //
        //                }
        //                commentsubView.sizeToFit()
        //
        //            }
        //
        //            contentView.addSubview(separator)
        
        //            if comment.children.isEmpty {
//                        separator.snp.makeConstraints {
//                            $0.top.equalTo(commentView.snp.bottom).offset(20)
//                            $0.leading.equalToSuperview().offset(30)
//                            $0.trailing.equalToSuperview().offset(-30)
//                            $0.height.equalTo(1)
//                        }
        //            } else {
        //                separator.snp.makeConstraints {
        //                    $0.top.equalTo(subCommentView[subCommentView.count-1].snp.bottom).offset(20)
        //                    $0.leading.equalToSuperview().offset(78)
        //                    $0.trailing.equalToSuperview().offset(-73)
        //                    $0.height.equalTo(1)
        //                }
        //            }
        
        
        
        
        
    }
    
    private func bind() {
        
        
    }
    
    
    
}

