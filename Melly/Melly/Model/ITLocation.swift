//
//  ITLocation.swift
//  Melly
//
//  Created by Jun on 2022/10/01.
//

import Foundation

struct ItLocation:Codable {
    var placeInfo:PlaceInfo
    let memoryInfo:[Memory]
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

struct PlaceList:Codable {
    let content: [Place]
    let pageable: Pageable
    let number: Int
    let sort: MemorySort
    let size, numberOfElements: Int
    let first, last, empty: Bool
}
