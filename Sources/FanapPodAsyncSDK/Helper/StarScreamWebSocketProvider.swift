//
//  StarScreamWebSocketProvider.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation
import Starscream

/// Starscream websocket provider. It'll be chosen automatically if the device is running iOS 12 and older.
class StarScreamWebSocketProvider :WebSocketProvider {

    /// A delegation provider to inform events.
    weak var delegate: WebSocketProviderDelegate?

    /// The socket to manage connection with the async server.
    private let socket: WebSocket

    /// The timeout to disconnect or retry if the connection has any trouble.
    private var timeout:TimeInterval

    /// The logger class for logging events and exceptions if it's not a runtime exception.
    private var logger                      : Logger

    /// The socket initializer.
    /// - Parameters:
    ///   - url: The base socket url.
    ///   - timeout: Socket timeout.
    ///   - logger: Logger to logs events and exceptions.
    init(url: URL, timeout:TimeInterval, logger:Logger) {
        self.logger = logger
        self.timeout = timeout
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = timeout
        self.socket = WebSocket(request: urlRequest)
        self.socket.disableSSLCertValidation = true
        self.socket.delegate = self        
    }

    /// A method to try to connect the web socket server.
    ///
    /// It'll be called by reconnecting or initializer.
    func connect() {
        self.socket.connect()
    }

    /// Send a message to the async server with the type of straem data.
    func send(data: Data) {
        self.socket.write(data: data)
    }

    /// Send a message to the async server with the type of text.
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
