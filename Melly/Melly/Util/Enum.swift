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

