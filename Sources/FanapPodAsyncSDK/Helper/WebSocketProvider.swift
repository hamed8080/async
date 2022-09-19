//
//  WebSocketProvider.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

/// A delegate to raise events.
internal protocol WebSocketProviderDelegate:AnyObject {

    /// A delegate method that informs the connection provider connected successfully.
    func webSocketDidConnect(_ webSocket:WebSocketProvider)

    /// A delegate method that informs the connection provider disconnected successfully.
    func webSocketDidDisconnect(_ webSocket:WebSocketProvider, _ error:Error?)

    /// A delegate method that informs the connection has received a message.
    func webSocketDidReciveData(_ webSocket:WebSocketProvider , didReceive data:Data)

    /// A delegate method that informs an error has happened.
    func webSocketReceiveError(_ error:Error?)
}

protocol WebSocketProvider:AnyObject{

    /// A delegation provider to inform events.
    var delegate:WebSocketProviderDelegate? {get set}

    /// A method to try to connect the WebSocket server.
    func connect()

    /// Force to close connection by client.
    func closeConnection()

    /// Send a message to the async server with the type of stream data.
    func send(data:Data)

    /// Send a message to the async server with the type of text.
    func send(text:String)
}
