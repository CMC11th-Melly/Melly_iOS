//
//  Enum.swift
//  Melly
//
//  Created by Jun on 2022/09/21.
//

import Foundation


struct MellyError: Error {
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
    case nameCountNotAvailable = "닉네임은 2자이상 8자이하입니다."
}

enum MemoryOpenType:String {
    case PRIVATE = "PRIVATE"
    case ALL = "ALL"
    case GROUP = "GROUP"
    
    static func getValue(_ text: String) -> MemoryOpenType {
         switch text {
         case "전체 공개":
             return .ALL
         case "선택한 메모리 그룹만 공개":
             return .GROUP
         case "비공개":
             return .PRIVATE
         default:
             return .ALL
         }
     }
    
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
    
    static func getGroupValue(_ text: String) -> String {
        switch text {
        case "FAMILY":
            return "가족"
        case "COMPANY":
            return "동료"
        case "COUPLE":
            return "연인"
        case "FRIEND":
            return "친구"
        default:
            return "모두"
        }
    }
    
    static func getGroupSurveyValue(_ text: String) -> String {
        switch text {
        case "가족":
            return "FAMILY"
        case "동료":
            return "COMPANY"
        case "연인":
            return "COUPLE"
        case "친구":
            return "FRIEND"
        default:
            return "모두"
        }
    }
    
}
