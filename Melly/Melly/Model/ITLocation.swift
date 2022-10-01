//
//  ITLocation.swift
//  Melly
//
//  Created by Jun on 2022/10/01.
//

import Foundation

struct ItLocation:Codable {
    let placeInfo:Place
    let memoryInfo:Place
}

struct Memory:Codable {
    let memoryId: Int
    let memoryImage:String
    let title:String
    let content:String
    
}

struct Place:Codable {
    let placeId:Int
    let placeImage:String
    let placeCategory:String
    let isScraped:Bool
    let placeName:String
}
