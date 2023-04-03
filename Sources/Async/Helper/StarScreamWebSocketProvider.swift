//
// StarScreamWebSocketProvider.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import Logger
import Starscream

/// Starscream websocket provider. It'll be chosen automatically if the device is running iOS 12 and older.
final class StarScreamWebSocketProvider: WebSocketProvider {
    /// A delegation provider to inform events.
    weak var delegate: WebSocketProviderDelegate?

    /// The socket to manage connection with the async server.
    private let socket: WebSocket

    /// The timeout to disconnect or retry if the connection has any trouble.
    private var timeout: TimeInterval

    /// The logger class for logging events and exceptions if it's not a runtime exception.
    private var logger: Logger

    /// The socket initializer.
    /// - Parameters:
    ///   - url: The base socket url.
    ///   - timeout: Socket timeout.
    ///   - logger: Logger to logs events and exceptions.
    init(url: URL, timeout: TimeInterval, logger: Logger) {
        self.logger = logger
        self.timeout = timeout
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = timeout
        socket = WebSocket(request: urlRequest)
        socket.disableSSLCertValidation = true
        socket.delegate = self
    }

    /// A method to try to connect the web socket server.
    ///
    /// It'll be called by reconnecting or initializer.
    func connect() {
        socket.connect()
    }

    /// Send a message to the async server with the type of straem data.
    func send(data: Data) {
        socket.write(data: data)
    }

    /// Send a message to the async server with the type of text.
    func send(text: String) {
        socket.write(string: text)
    }

    /// Force to close conection by Client
    func closeConnection() {
        socket.disconnect()
    }
}

extension StarScreamWebSocketProvider: Starscream.WebSocketDelegate {
    func websocketDidConnect(socket _: WebSocketClient) {
        delegate?.webSocketDidConnect(self)
    }

    func websocketDidDisconnect(socket _: WebSocketClient, error: Error?) {
        delegate?.webSocketDidDisconnect(self, error)
    }

    func websocketDidReceiveMessage(socket _: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else { return }
        delegate?.webSocketDidReciveData(self, didReceive: data)
    }

    func websocketDidReceiveData(socket _: WebSocketClient, data: Data) {
        delegate?.webSocketDidReciveData(self, didReceive: data)
    }
}
