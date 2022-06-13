//
//  StarScreamWebSocketProvider.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation
import Starscream

class StarScreamWebSocketProvider :WebSocketProvider {

    weak var delegate: WebSocketProviderDelegate?
    private let socket: WebSocket
    private var timeout:TimeInterval
    private var logger                      : Logger
    
    init(url: URL, timeout:TimeInterval, logger:Logger) {
        self.logger = logger
        self.timeout = timeout
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = timeout
        self.socket = WebSocket(request: urlRequest)
        self.socket.disableSSLCertValidation = true
        self.socket.delegate = self        
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
    
    func send(text: String) {
        self.socket.write(string: text)
    }
    
    /// Force to close conection by Client
    func closeConnection() {
        socket.disconnect()
    }
    
}

extension StarScreamWebSocketProvider : Starscream.WebSocketDelegate{
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.webSocketDidConnect(self)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.webSocketDidDisconnect(self,error)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8)else{return}
        self.delegate?.webSocketDidReciveData(self, didReceive: data)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        self.delegate?.webSocketDidReciveData(self, didReceive: data)
    }
}
