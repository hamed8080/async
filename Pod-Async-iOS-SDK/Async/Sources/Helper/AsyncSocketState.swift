//
//  AsyncSocketState.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

/// The current state of the socket.
public enum AsyncSocketState:String{

    /// The socket is trying to connect again.
    case CONNECTING  = "CONNECTING"

    /// The socket is already connected.
    case CONNECTED   = "CONNECTED"

    /// The socket closed due to weak internet connectivity or an error that had happened on the server.
    case CLOSED      = "CLOSED"

    /// Async is ready to use.
    case ASYNC_READY = "ASYNC_READY"
}
