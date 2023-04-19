//
// Async.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Additive
import Foundation
import Logger

public final class Async: WebSocketProviderDelegate {
    private weak var delegate: AsyncDelegate?
    private(set) var config: AsyncConfig
    private(set) var socket: WebSocketProvider?
    private(set) var asyncStateModel: AsyncStateModel = .init()
    private weak var reconnectTimer: Timer?
    private weak var pingTimer: Timer?
    private var connectionStatusTimer: Timer?
    private var logger: Logger

    /// The initializer of async.
    ///
    /// After creating this object you should call ``Async/createSocket()`` to start connecting to the server unless it's not connected automatically.
    /// - Parameters:
    ///   - config: Configuration of async ``AsyncConfig``.
    ///   - delegate: Delegate to notify events.
    public init(config: AsyncConfig, delegate: AsyncDelegate? = nil) {
        logger = Logger(config: config.loggerConfig)
        self.config = config
        self.delegate = delegate
        logger.delegate = delegate
        checkConnectionTimer()
    }

    /// Create and connect to the socket for the first tiem and notify the connection state if delegate is setted.
    ///
    /// It'll connect through Apple native socket in iOS 13 and above, on the other hand, it'll connect through StarScream in older devices.
    public func createSocket() {
        setSocketState(socketState: .connecting)
        if #available(iOS 13.0, *) {
            socket = NativeWebSocketProvider(url: URL(string: config.socketAddress)!, timeout: config.connectionRetryInterval, logger: logger)
        } else {
            socket = StarScreamWebSocketProvider(url: URL(string: config.socketAddress)!, timeout: config.connectionRetryInterval, logger: logger)
        }
        socket?.delegate = self
        socket?.connect()
    }

    /// Reconnect when you want to connect again.
    public func reconnect() {
        setSocketState(socketState: .connecting)
        socket?.connect()
    }

    func webSocketDidConnect(_: WebSocketProvider) {
        setSocketState(socketState: .connected)
        socketConnected()
    }

    func webSocketDidDisconnect(_: WebSocketProvider, _ error: Error?) {
        logger.log(message: "Disconnected with error:\(String(describing: error))", persist: false, type: .internalLog)
        setSocketState(socketState: .closed, error: error)
        DispatchQueue.main.async { [weak self] in
            if self?.config.reconnectOnClose == true {
                self?.tryToReconnectToSocket()
            }
        }
    }

    func webSocketReceiveError(_ error: Error?) {
        logger.log(message: "Received Error:\(String(describing: error))", persist: true, type: .internalLog, userInfo: loggerUserInfo)
        if asyncStateModel.lastMessageRCVDate == nil {
            // This block means if the user doesn't access the internet and try to connect for the first time he must get a CLOSE state
            DispatchQueue.main.async { [weak self] in
                self?.setSocketState(socketState: .closed, error: error)
                self?.tryToReconnectToSocket()
            }
        }
    }

    func webSocketDidReciveData(_: WebSocketProvider, didReceive data: Data) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.messageReceived(data: data)
        }
    }

    private func prepareTimerForNextPing() {
        pingTimer?.invalidate()
        pingTimer = nil
        pingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.sendPing()
        }
    }

    private func socketConnected() {
        asyncStateModel.retryCount = 0
        reconnectTimer = nil
    }

    private func tryToReconnectToSocket() {
        if config.reconnectOnClose == true, reconnectTimer == nil {
            reconnectTimer?.invalidate()
            reconnectTimer = nil
            reconnectTimer = Timer.scheduledTimer(withTimeInterval: config.connectionRetryInterval, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                if self.asyncStateModel.socketState == .connected || self.asyncStateModel.socketState == .asyncReady {
                    timer.invalidate()
                    return
                }
                if self.asyncStateModel.retryCount < self.config.reconnectCount {
                    self.asyncStateModel.retryCount += 1
                    self.logger.log(message: "Try reconnect for \(self.asyncStateModel.retryCount) times", persist: false, type: .internalLog)
                    self.reconnect()
                } else {
                    self.logger.log(message: "Failed to reconnect after \(self.config.reconnectCount) tries", persist: false, type: .internalLog)
                    timer.invalidate()
                }
            }
        }
    }

    /// Send data to server.
    ///
    ///  The message will send only if the socket state is in ``AsyncSocketState/asyncReady`` mode unless the message will be queued and after connecting to the server it sends those messages.
    /// - Parameters:
    ///   - type: The type of async message. For most of the times it will use ``AsyncMessageTypes/message``.
    ///   - data: If you pass nil nothing happend here.
    public func sendData(type: AsyncMessageTypes, message: SendAsyncMessageVO?) {
        guard let data = try? JSONEncoder.instance.encode(message) else { return }
        let asyncSendMessage = AsyncMessage(content: data.utf8String, type: type)
        let asyncMessageData = try? JSONEncoder.instance.encode(asyncSendMessage)
        if asyncStateModel.socketState == .asyncReady {
            logger.logJSON(title: "Send message", jsonString: asyncSendMessage.string ?? "", persist: false, type: .sent)
            guard let asyncMessageData = asyncMessageData, let string = String(data: asyncMessageData, encoding: .utf8) else { return }
            socket?.send(text: string)
            delegate?.asyncMessageSent(message: asyncMessageData, error: nil)
        } else {
            delegate?.asyncMessageSent(message: nil, error: AsyncError(code: .socketIsNotConnected))
        }
    }

    /// Notify and close the current connection.
    public func closeConnection() {
        setSocketState(socketState: .closed)
        socket?.closeConnection()
    }

    private func registerDevice() {
        let register: RegisterDevice = asyncStateModel.peerId == nil ?
            .init(renew: true, appId: config.appId, deviceId: asyncStateModel.deviceId ?? "") :
            .init(refresh: true, appId: config.appId, deviceId: asyncStateModel.deviceId ?? "")

        if let data = try? JSONEncoder.instance.encode(register) {
            sendConnectionData(type: .deviceRegister, data: data)
        }
    }

    private func registerServer() {
        let register = RegisterServer(name: config.serverName)
        if let data = try? JSONEncoder.instance.encode(register) {
            sendConnectionData(type: .serverRegister, data: data)
        }
    }

    private func sendACK(asyncMessage: AsyncMessage) {
        if let id = asyncMessage.id {
            let messageACK = MessageACK(messageId: id)
            if let data = try? JSONEncoder.instance.encode(messageACK) {
                sendConnectionData(type: .ack, data: data)
            }
        }
    }

    private func sendPing() {
        sendConnectionData(type: .ping, data: nil)
    }

    private func sendConnectionData(type: AsyncMessageTypes, data: Data?) {
        let asyncSendMessage = AsyncMessage(content: data?.utf8String, type: type)
        let asyncMessageData = try? JSONEncoder.instance.encode(asyncSendMessage)
        logger.logJSON(title: "Send an internal message", jsonString: asyncSendMessage.string ?? "", persist: false, type: .sent)
        guard let asyncMessageData = asyncMessageData, let string = String(data: asyncMessageData, encoding: .utf8) else { return }
        socket?.send(text: string)
    }

    private func checkConnectionTimer() {
        connectionStatusTimer?.invalidate()
        connectionStatusTimer = nil
        connectionStatusTimer = Timer.scheduledTimer(withTimeInterval: config.connectionCheckTimeout, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let lastMSG = self.asyncStateModel.lastMessageRCVDate, lastMSG.timeIntervalSince1970 + self.config.connectionCheckTimeout < Date().timeIntervalSince1970 {
                self.setSocketState(socketState: .closed, error: nil)
                self.tryToReconnectToSocket()
            }
        }
    }

    /// Dispose and try to disconnect immediately and release all related objects.
    public func disposeObject() {
        connectionStatusTimer?.invalidate()
        pingTimer?.invalidate()
        reconnectTimer?.invalidate()
        connectionStatusTimer = nil
        pingTimer = nil
        reconnectTimer = nil
        socket = nil
        delegate = nil
    }
}

// async on Message Received Handler
extension Async {
    private func messageReceived(data: Data) {
        guard let asyncMessage = try? JSONDecoder.instance.decode(AsyncMessage.self, from: data) else {
            logger.log(message: "Can not decode data", persist: false, type: .internalLog)
            return
        }
        logger.logJSON(title: "On Receive Message", jsonString: asyncMessage.string ?? "", persist: false, type: .received)
        prepareTimerForNextPing()
        asyncStateModel.setLastMessageReceiveDate()
        switch asyncMessage.type {
        case .ping:
            onPingMessage(asyncMessage: asyncMessage)
        case .serverRegister:
            onServerRegisteredMessage(asyncMessage: asyncMessage)
        case .deviceRegister:
            onDeviceRegisteredMessage(asyncMessage: asyncMessage)
        case .message:
            delegate?.asyncMessage(asyncMessage: asyncMessage)
        case .messageAckNeeded, .messageSenderAckNeeded:
            sendACK(asyncMessage: asyncMessage)
            delegate?.asyncMessage(asyncMessage: asyncMessage)
        case .ack:
            delegate?.asyncMessage(asyncMessage: asyncMessage)
        case .getRegisteredPeers:
            break
        case .peerRemoved:
            break
        case .registerQueue:
            break
        case .notRegistered:
            break
        case .errorMessage:
            break
        case .none:
            logger.createLog(message: "UNKOWN type received", persist: true, level: .error, type: .internalLog, userInfo: loggerUserInfo)
        }
    }

    private func onPingMessage(asyncMessage: AsyncMessage) {
        if asyncMessage.content != nil {
            if asyncStateModel.deviceId == nil {
                asyncStateModel.setDeviceId(deviceId: asyncMessage.content)
            }
            registerDevice()
        }
    }

    private func onDeviceRegisteredMessage(asyncMessage: AsyncMessage) {
        asyncStateModel.isDeviceRegistered = true
        let oldPeerId = asyncStateModel.peerId
        if let peerIdString = asyncMessage.content {
            asyncStateModel.setPeerId(peerId: Int(peerIdString))
        }

        if asyncStateModel.isServerRegistered == true, asyncStateModel.peerId == oldPeerId {
            setSocketState(socketState: .asyncReady)
        } else {
            registerServer()
        }
    }

    private func onServerRegisteredMessage(asyncMessage: AsyncMessage) {
        if asyncMessage.senderName == config.serverName {
            asyncStateModel.isServerRegistered = true
            setSocketState(socketState: .asyncReady)
        } else {
            registerServer()
        }
    }

    private func setSocketState(socketState: AsyncSocketState, error: Error? = nil) {
        asyncStateModel.setSocketState(socketState: socketState)
        logger.log(message: "Connection State Changed to: \(socketState)", persist: false, type: .internalLog)
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.asyncStateChanged(asyncState: socketState, error: error == nil ? nil : .init(rawError: error))
        }
    }
}
