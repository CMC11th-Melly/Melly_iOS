//
//  Marker.swift
//  Melly
//
//  Created by Jun on 2022/09/29.
//

import Foundation

struct Position:Codable {
    
    let lat:Double
    let lng: Double
    
}

struct Marker:Codable {
    
    let position:Position
    let placeId:Int
    let memoryCount:Int
    
}
