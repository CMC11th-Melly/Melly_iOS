//
//  SearchLocation.swift
//  Melly
//
//  Created by Jun on 2022/10/06.
//

import Foundation


struct SearchLocation: Codable {
    
    let lastBuildDate: String
    let total:Int
    let start:Int
    let display:Int
    let items:[LocationItem]
    
    
}


struct LocationItem: Codable {
    
    let title: String
    let link: String
    let category, description, telephone, address: String
    let roadAddress, mapx, mapy: String
    
}
