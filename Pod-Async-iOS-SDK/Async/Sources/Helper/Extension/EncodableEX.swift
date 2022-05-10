//
//  EncodableEX.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/27/21.
//

import Foundation
extension Encodable{
    var data:Data?{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(self)
        return data
    }
    
    public var string:String?{
        guard let data = data else {
            return nil
        }
        let string = String(data: data, encoding: .utf8)
        return string
    }
}
