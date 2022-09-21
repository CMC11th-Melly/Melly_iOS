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
    case kakao = "kakao"
    case naver = "naver"
    case google = "google"
    case apple = "apple"
    case Default = "DEFAULT"
}
