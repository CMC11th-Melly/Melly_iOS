//
//  FoundationExtension.swift
//  Melly
//
//  Created by Jun on 2022/09/21.
//

import Foundation

extension Encodable {
    
    func encode() throws -> [String:Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {
            throw NSError()
        }
        
        return dictionary
    }
    
}

extension Decodable {
    static func decode<T: Decodable>(dictionary: [String:Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [.fragmentsAllowed])
        return try JSONDecoder().decode(T.self, from: data)
    }
    
}

func dictionaryToObject<T:Decodable>(objectType:T.Type,dictionary:[String:Any]) -> T? {
    
    guard let dictionaries = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    guard let objects = try? decoder.decode(T.self, from: dictionaries) else { return nil }
    return objects
    
}

extension String {
    
    
    /**
    용량을 단위별로 바꿔주는 함수
     - Parameters:
            -fileSize: Int
     - Throws: None
     - Returns:String(ex: 10GB)
     */
   static func formatSize(fileSize: Int) -> String{
        var measure = "bytes"
        var size = Double(fileSize)
        
        if (size >= pow(1024, 4)) { measure = "TB" }
        else if (size >= pow(1024, 3)) { measure = "GB" }
        else if (size >= pow(1024, 2)) { measure = "MB" }
        else if (size >= pow(1024, 1)) { measure = "KB" }
        
        for _ in 0..<3 {
            if size >= 1024 {
                size /= 1024
            }
        }
        
        if size == round(size) {
            return String(format: "%.0f", size) + measure
        } else if size == round(size * 10) / 10 {
            return String(format: "%.1f", size) + measure
        } else {
            return String(format: "%.2f", size) + measure
        }
    }
}

