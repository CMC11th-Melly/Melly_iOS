//
//  Comment.swift
//  Melly
//
//  Created by Jun on 2022/10/26.
//

import Foundation

struct Comment:Codable {
    
    let id:Int
    let nickname:String?
    let content:String
    let isLoginUserWrite:Bool
    let isLoginUserLike:Bool
    let likeCount:Int
    let profileImage:String?
    let createdDate:String?
    let mentionUserName:String?
    let writerId:Int
    let children:[Comment]
    
}

struct CommentData:Codable {
    
    let commentCount:Int
    let comments:[Comment]
    
}
