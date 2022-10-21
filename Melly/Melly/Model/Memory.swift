//
//  Memory.swift
//  Melly
//
//  Created by Jun on 2022/10/19.
//

import Foundation

struct Memory:Codable {
    let memoryId: Int
    let memoryImages:[String]
    let title:String
    let content:String
    let groupName:String?
    let groupType:String?
    let visitedDate:String
    let stars:Int
    let keyword:String
}

struct MemoryData:Codable {
    let memoryCount: Int
    let memoryList: MemoryList
}

struct MemoryList:Codable {
    let content: [Memory]
    let pageable: Pageable
    let number: Int
    let sort: MemorySort
    let size, numberOfElements: Int
    let first, last, empty: Bool
}

struct MemorySort: Codable {
    let empty, unsorted, sorted: Bool
}

struct Pageable: Codable {
    let sort: MemorySort
    let offset, pageSize, pageNumber: Int
    let paged, unpaged: Bool
}
