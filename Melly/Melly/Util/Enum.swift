//
//  Enum.swift
//  Melly
//
//  Created by Jun on 2022/09/21.
//

import Foundation

public struct MellyError: Error {
    var code: Int
    var msg: String
}

enum MenuState {
    case opened
    case closed
}

enum LoginType:String {
    case kakao = "KAKAO"
    case naver = "NAVER"
    case google = "GOOGLE"
    case apple = "APPLE"
    case Default = "DEFAULT"
}

enum EmailValid:String {
    case notAvailable = "올바른 이메일 형식이 아닙니다."
    case alreadyExsist = "이미 존재하는 아이디입니다."
    case serverError = "네트워크 상태를 확인해주세요."
    case correct = ""
    case nameNotAvailable = "이름은 한글, 영어만 입력 가능해요."
    case nameCountNotAvailable = "2자리 이상 입력해주세요."
}

enum GroupFilter: String {
    case family = "FAMILY"
    case company = "COMPANY"
    case couple = "COUPLE"
    case friend = "FRIEND"
    case all = "ALL"
    // FAMILY, COMPANY, COUPLE, FRIEND, ALL
    
    
   static func getValue(_ text: String) -> GroupFilter {
        switch text {
        case "연인만":
            return .couple
        case "가족만":
            return .family
        case "동료만":
            return .company
        case "친구만":
            return .friend
        default:
            return .all
        }
    }
    
    static func getKoValue(_ text: String) -> String {
        switch text {
        case "FAMILY":
            return "가족과"
        case "COMPANY":
            return "동료와"
        case "COUPLE":
            return "연인과"
        case "FRIEND":
            return "친구와"
        default:
            return "모두와"
        }
    }
    
}
