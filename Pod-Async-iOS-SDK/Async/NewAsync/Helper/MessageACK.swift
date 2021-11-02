//
//  MessageACK.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation
struct MessageACK : Codable{
  
    var messageId  : Int64
    
    public init(messageId: Int64) {
        self.messageId      = messageId
    }
}
