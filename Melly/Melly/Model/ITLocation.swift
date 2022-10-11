//
//  ITLocation.swift
//  Melly
//
//  Created by Jun on 2022/10/01.
//

import Foundation

struct ItLocation:Codable {
    let placeInfo:PlaceInfo
    let memoryInfo:[Memory]
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

struct PlaceInfo:Codable {
    
    let placeId:Int
    var isScraped:Bool
    var placeImage:String?
    var placeCategory:String
    var placeName:String
    let recommendType:String
}

struct Place:Codable {
    let placeId:Int
    let position:Position
    let myMemoryCount:Int
    let otherMemoryCount:Int
    var placeImage:String?
    var placeCategory:String
    var isScraped:Bool
    var placeName:String
    let recommendType:String
}
