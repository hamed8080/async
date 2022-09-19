//
//  RegisterDevice.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation
struct RegisterServer : Codable{

    /// The name of the server.
    var name          : String

    /// The name of the server.
    /// - Parameter name: The server name.
    public init(name: String) {
        self.name      = name
    }
}
