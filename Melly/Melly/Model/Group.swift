//
//  Group.swift
//  Melly
//
//  Created by Jun on 2022/10/18.
//

import Foundation

struct Group:Codable {
    
    let groupId:Int
    var groupIcon: Int
    var groupName: String
    var users: [UserInfo]
    var groupType: String
    let invitationLink: String?
    
}

struct UserInfo: Codable {
    let userID: Int
    let profileImage: String?
    let nickname: String
    let isLoginUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case profileImage, nickname, isLoginUser
    }
}
