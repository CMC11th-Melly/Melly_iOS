//
//  User.swift
//  Melly
//
//  Created by Jun on 2022/09/14.
//

import Foundation

struct User: Codable, Identifiable {
    
    var id = UUID()
    var email:String = ""
    var pw:String = ""
    var name:String = "머식"
    var gender:String = ""
    
}
