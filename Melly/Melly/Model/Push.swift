//
//  Push.swift
//  Melly
//
//  Created by Jun on 2022/11/04.
//

import Foundation

struct Push: Codable {
    
    let notificationId:Int
    let type:String
    let date:String
    var checked:Bool
    let content:String
    let memory:Memory
    
}
