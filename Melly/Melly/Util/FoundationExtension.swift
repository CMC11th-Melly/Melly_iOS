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
