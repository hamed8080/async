//
//  StringEX.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 11/7/21.
//

import Foundation

extension String{
    
    public func removeBackSlashes()->String{
        return self.replacingOccurrences(of: "\\\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\"{", with: "\n{")
        .replacingOccurrences(of: "}\"", with: "}\n")
        .replacingOccurrences(of: "\"[", with: "\n[")
        .replacingOccurrences(of: "]\"", with: "]\n")
    }
    
    public func preetyJsonString()->String{
        let string = self.removeBackSlashes()
        let stringData = string.data(using: .utf8) ?? Data()
        if let jsonObject = try? JSONSerialization.jsonObject(with: stringData, options: .mutableContainers),
           let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        {
            let prettyString = String(data: prettyJsonData, encoding: .utf8) ?? ""
            return prettyString
        }else if let data = self.data(using: .utf8),
                 let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                 let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        {
            let prettyString = String(data: prettyJsonData, encoding: .utf8) ?? ""
            return prettyString.removeBackSlashes()
        }else{
            return ""
        }
    }
}
