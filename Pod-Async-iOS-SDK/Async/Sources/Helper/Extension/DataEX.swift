//
//  DataEX.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/25/21.
//

import Foundation

extension Data{
    func string()->String?{
        return String(data: self, encoding: .utf8)
    }
}
