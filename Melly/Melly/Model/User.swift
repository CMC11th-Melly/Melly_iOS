//
//  User.swift
//  Melly
//
//  Created by Jun on 2022/09/14.
//

import Foundation

struct User: Codable, Identifiable {
    
    static var loginedUser:User?
    
    enum Codingkeys: String, CodingKey {
        case id = "uid"
        case email
        case pw = "password"
        case nickname
        case gender
        case provider
        case ageGroup
        case userSeq
        case profileImage
    }
    
    var id = UUID().uuidString
    var email:String = ""
    var pw:String = ""
    var nickname:String = ""
    var gender:String = ""
    var provider:String = "DEFAULT"
    var userSeq = 1
    var profileImage:String? = nil
    var ageGroup:String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(String.self, forKey: .id)) ?? ""
        self.email = (try? container.decode(String.self, forKey: .email)) ?? ""
        self.pw = (try? container.decode(String.self, forKey: .pw)) ?? ""
        self.nickname = (try? container.decode(String.self, forKey: .nickname)) ?? ""
        self.gender = (try? container.decode(String.self, forKey: .gender)) ?? ""
        self.provider = (try? container.decode(String.self, forKey: .provider)) ?? ""
        self.userSeq = (try? container.decode(Int.self, forKey: .userSeq)) ?? 0
        self.profileImage = try? container.decodeIfPresent(String.self, forKey: .profileImage)
        self.ageGroup = (try? container.decode(String.self, forKey: .ageGroup)) ?? ""
    }
    
    init() {}
    
    
}


