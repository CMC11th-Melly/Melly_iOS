//
//  SearchLocation.swift
//  Melly
//
//  Created by Jun on 2022/10/06.
//

import Foundation
import NMapsMap

struct SearchLocation: Codable {
    
    let lastBuildDate: String
    let total:Int
    let start:Int
    let display:Int
    let items:[LocationItem]
    
    
}



struct Search {
    let img:String
    let title:String
    var category:String = ""
    var lat:Double = 0
    var lng:Double = 0
    var isRecent:Bool = false
    var placeId:Int = -1
    
    
    init(_ location: LocationItem, type: Bool) {
        
        if type {
            self.img = "search_location"
        } else {
            self.img = "search_memory"
        }
        
        let title = location.title.components(separatedBy: "<b>").joined().components(separatedBy: "</b>").joined()
        self.title = title
        self.category = location.category.components(separatedBy: ">")[0]
        
        
        let x = Double(Int(location.mapx) ?? 0)
        let y = Double(Int(location.mapy) ?? 0)
        
        let gmt = NMGTm128(x: x, y: y)
        
        self.lat = gmt.toLatLng().lat
        self.lng = gmt.toLatLng().lng
        
    }
    
    init(_ memory: SearchMemory) {
        self.img = "search_memory"
        self.placeId = memory.placeId
        self.title = memory.memoryName
    }
    
    
}

struct LocationItem: Codable {
    
    let title: String
    let link: String
    let category, description, telephone, address: String
    let roadAddress, mapx, mapy: String
    
}

struct SearchMemory: Codable {
    
    let placeId:Int
    let memoryName:String
    
}
