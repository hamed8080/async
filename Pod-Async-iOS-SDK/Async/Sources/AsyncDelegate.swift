//
//  AsyncDelegate.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

public protocol AsyncDelegate:class{
    func asyncMessage(asyncMessage:AsyncMessage)
    func asyncStateChanged(asyncState:AsyncSocketState, error:AsyncError?)
    func asyncMessageSent(message:Data)
    func asyncError(error:AsyncError)
}
