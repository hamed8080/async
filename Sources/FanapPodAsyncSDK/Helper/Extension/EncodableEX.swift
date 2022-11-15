//
// EncodableEX.swift
// Copyright (c) 2022 FanapPodAsyncSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
extension Encodable {
    /// Convert the encodable to the data.
    var data: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(self)
        return data
    }

    /// A string value of encodable.
    public var string: String? {
        guard let data = data else {
            return nil
        }
        let string = String(data: data, encoding: .utf8)
        return string
    }
}
