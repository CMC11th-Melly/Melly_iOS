//
//  Group.swift
//  Melly
//
//  Created by Jun on 2022/10/18.
//

import Foundation

struct Group: Codable {
    let groupID: Int
    let groupIcon: String?
    let groupName, groupType: String
    let invitationLink: String
    let createdDate: String
    let userInfo: [UserInfo]

    enum CodingKeys: String, CodingKey {
        case groupID = "groupId"
        case groupIcon, groupName, groupType, invitationLink, createdDate, userInfo
    }
}

struct UserInfo: Codable {
    let uid: String
    let profileImage: String
    let nickname: String
}
