//
//  Group.swift
//  Melly
//
//  Created by Jun on 2022/10/18.
//

import Foundation

struct Group:Codable {
    
    let groupId, groupIcon: Int
    let groupName: String
    let users: [UserInfo]
    let groupType: String
    let invitationLink: String
    
    
}

struct UserInfo: Codable {
    let userID: Int
    let profileImage: String
    let nickname: String
    let isLoginUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case profileImage, nickname, isLoginUser
    }
}
