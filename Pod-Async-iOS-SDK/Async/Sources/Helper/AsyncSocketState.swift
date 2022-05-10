//
//  AsyncSocketState.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

public enum AsyncSocketState:String{
    case CONNECTING  = "CONNECTING"
    case CONNECTED   = "CONNECTED"
    case CLOSED      = "CLOSED"
    case ASYNC_READY = "ASYNC_READY"
}
