//
//  ResponseData.swift
//  Melly
//
//  Created by Jun on 2022/09/21.
//

import Foundation

struct ResponseData: Decodable {
    
    var code:Int
    var message:String
    var data:[String:Any]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = (try? values.decode(Int.self, forKey: .code)) ?? 0
        self.message = (try? values.decode(String.self, forKey: .message)) ?? "관리자에게 문의해주세요."
        self.data = (try? values.decode([String:Any].self, forKey: .data))

    }

    enum CodingKeys: CodingKey {
        case code
        case message
        case data
    }
    
}
