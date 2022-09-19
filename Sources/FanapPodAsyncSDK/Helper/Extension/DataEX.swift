//
//  DataEX.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/25/21.
//

import Foundation

extension Data{

    /// A converter extension that converts data to string with UTF-8.
    func string()->String?{
        return String(data: self, encoding: .utf8)
    }
}
