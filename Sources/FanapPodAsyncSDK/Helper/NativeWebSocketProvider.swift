//
// NativeWebSocketProvider.swift
// Copyright (c) 2022 FanapPodAsyncSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

@available(iOS 13.0, *)

/// iOS native websocket provider. It'll be chosen automatically if the device is running iOS 13+.
class NativeWebSocketProvider: NSObject, WebSocketProvider, URLSessionDelegate, URLSessionWebSocketDelegate {
    /// A delegation provider to inform events.
    weak var delegate: WebSocketProviderDelegate?

    /// The socket to manage connection with the async server.
    private weak var socket: URLSessionWebSocketTask?

    /// The timeout to disconnect or retry if the connection has any trouble.
    private var timeout: TimeInterval!

    /// The base url of the socket.
    private var url: URL!

    /// A value that indicates neither socket is connected or not.
    private(set) var isConnected: Bool = false

    /// The logger class for logging events and exceptions if it's not a runtime exception.
    private weak var logger: Logger?

    /// The socket initializer.
    /// - Parameters:
    ///   - url: The base socket url.
    ///   - timeout: Socket timeout.
    ///   - logger: Logger to logs events and exceptions.
    init(url: URL, timeout: TimeInterval, logger: Logger) {
        self.timeout = timeout
        self.url = url
        self.logger = logger
        super.init()
    }

    /// A method to try to connect the web socket server.
    ///
    /// It'll be called by reconnecting or initializer.
    public func connect() {
        let configuration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        var urlRequest = URLRequest(url: url, timeoutInterval: timeout)
        urlRequest.networkServiceType = .responsiveData
        socket = urlSession.webSocketTask(with: urlRequest)
        socket?.resume()
        readMessage()
    }

    /// Send a message to the async server with a type of stream data.
    func send(data: Data) {
        if isConnected {
            socket?.send(.data(data)) { [weak self] error in
                self?.handleError(error)
            }
        }
    }

    /// Send a message to the async server with a type of text.
    func send(text: String) {
        if isConnected {
            socket?.send(.string(text)) { [weak self] error in
                self?.handleError(error)
            }
        }
    }

    /// A read message receiver. It'll be called again on receiving a message to stay awake for the next message.
    private func readMessage() {
        socket?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                break
            case let .success(message):
                switch message {
                case let .data(data):
                    self.delegate?.webSocketDidReciveData(self, didReceive: data)
                case let .string(string):
                    self.delegate?.webSocketDidReciveData(self, didReceive: string.data(using: .utf8)!)
                @unknown default:
                    self.logger?.log(title: "un implemented case found in NativeWebSocketProvider")
                }
                self.readMessage()
            }
        }
    }

    /// It'll be called by the os whenever a connection opened successfully.
    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didOpenWithProtocol _: String?) {
        isConnected = true
        delegate?.webSocketDidConnect(self)
    }

    /// It'll be called by the os whenever a connection dropped.
    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didCloseWith _: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        if let reason = reason {
            logger?.log(title: String(data: reason, encoding: .utf8) ?? "")
        }
        isConnected = false
    }

    /// trust the credential for the desired URL if it's not valid or trusted by issuers.
    ///
    /// Never call delegate?.webSocketDidDisconnect in this method it leads to close next connection
    func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }

    ///  Whenever an error has happened the error will be raised and passed to the event.
    func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            handleError(error)
        }
    }

    /// Force to close connection by Client.
    func closeConnection() {
        socket?.cancel(with: .goingAway, reason: nil)
    }

    /// An error handler to check if the connection should be marked as closed or if it's alive but an error has happened.
    ///
    /// we need to check if the error code is one of the 57, 60, 54 timeouts no network and internet offline to notify the delegate we disconnected from the internet
    private func handleError(_ error: Error?) {
        if let error = error as NSError? {
            if error.code == 57 || error.code == 60 || error.code == 54 {
                isConnected = false
                closeConnection()
                delegate?.webSocketDidDisconnect(self, error)
            } else {
                delegate?.webSocketReceiveError(error)
            }
        }
    }
}
