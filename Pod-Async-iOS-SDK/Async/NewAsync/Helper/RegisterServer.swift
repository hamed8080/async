//
//  RegisterDevice.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation
struct RegisterServer : Codable{
  
    var name          : String
    
    public init(name: String) {
        self.name      = name
    }
}
