//
//  NewAsyncMessage.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation
public struct NewAsyncMessage : Codable{
    
    public var content        : String?
    public var senderName     : String?
    public var id             : Int64?
    public var type           : AsyncMessageTypes?
    public var senderId       : Int64?
}
