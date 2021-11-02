//
//  NewAsyncDelegate.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

public protocol NewAsyncDelegate{    
    func asyncMessage(asyncMessage:NewAsyncMessage)
    func asyncStateChanged(asyncState:AsyncSocketState, error:AsyncError?)
    func asyncMessageSent(message:Data)
    func asyncError(error:AsyncError)
}
