//
//  ITLocation.swift
//  Melly
//
//  Created by Jun on 2022/10/01.
//

import Foundation

struct ItLocation:Codable {
    let placeInfo:Place
    let memoryInfo:Memory
}

struct Memory:Codable {
    let memoryId: Int
    let memoryImages:[String]
    let title:String
    let content:String
    let groupName:String
    let stars:Int
    let keywords:[String]
    
}

struct Place:Codable {
    let placeId:Int
    let placeImage:String
    let placeCategory:String
    let isScraped:Bool
    let placeName:String
    let recommendType:String
}
