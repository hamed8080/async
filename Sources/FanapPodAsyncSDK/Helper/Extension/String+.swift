//
// String+.swift
// Copyright (c) 2022 FanapPodAsyncSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension String {
    /// Remove backslashes for pretty print.
    func removeBackSlashes() -> String {
        replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: "\"{", with: "\n{")
            .replacingOccurrences(of: "}\"", with: "}\n")
            .replacingOccurrences(of: "\"[", with: "\n[")
            .replacingOccurrences(of: "]\"", with: "]\n")
    }

    /// Pretty print of a JSON.
    func preetyJsonString() -> String {
        let string = removeBackSlashes()
        let stringData = string.data(using: .utf8) ?? Data()
        if let jsonObject = try? JSONSerialization.jsonObject(with: stringData, options: .mutableContainers),
           let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        {
            let prettyString = String(data: prettyJsonData, encoding: .utf8) ?? ""
            return prettyString.removeBackSlashes()
        } else {
            return ""
        }
    }
}
