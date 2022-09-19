//
//  MessageACK.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

/// The message acknowledge request/response.
struct MessageACK : Codable{

    /// Message Id that got/received an acknowledgment.
    var messageId  : Int64

    /// Initializer for the message acknowledgment.
    public init(messageId: Int64) {
        self.messageId      = messageId
    }
}
