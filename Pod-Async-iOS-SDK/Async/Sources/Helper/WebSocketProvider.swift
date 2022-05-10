//
//  WebSocketProvider.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation
internal protocol WebSocketProviderDelegate:AnyObject {
    func webSocketDidConnect(_ webSocket:WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket:WebSocketProvider, _ error:Error?)
    func webSocketDidReciveData(_ webSocket:WebSocketProvider , didReceive data:Data)
    func webSocketReceiveError(_ error:Error?)
}

protocol WebSocketProvider:AnyObject{
    var delegate:WebSocketProviderDelegate? {get set}
    func connect()
    func closeConnection()
    func send(data:Data)
    func send(text:String)
}
