//
// Async.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Additive
import Foundation
import Logger

/// It will connect through Apple native socket in iOS 13 and above, unless it will connect through StarScream in older devices.
public final class Async: AsyncInternalProtocol, WebSocketProviderDelegate {
    public weak var delegate: AsyncDelegate?
    var config: AsyncConfig
    var socket: WebSocketProvider
    var queue: DispatchQueueProtocol
    var stateModel: AsyncStateModel = .init()
    var reconnectTimer: TimerProtocol?
    var pingTimer: TimerProtocol?
    var connectionStatusTimer: TimerProtocol?
    var logger: Logger
    var isDisposed: Bool = false
    /// This queue prevents the concurrent queue from calling the onReceive method from different queues and causes a data race.
    private let syncQueue = DispatchQueue(label: "SyncQueue")

    /// The initializer of async.
    ///
    /// After creating this object you should call ``Async/createSocket()`` to start connecting to the server unless it's not connected automatically.
    /// - Parameters:
    ///   - socket: A socket provider.
    ///   - config: Configuration of async ``AsyncConfig``.
    ///   - delegate: Delegate to notify events.
    ///   - queue: A queue in which respones back.
    public init(socket: WebSocketProvider, config: AsyncConfig, delegate: AsyncDelegate? = nil, logger: Logger, queue: DispatchQueueProtocol = DispatchQueue(label: "ASYNC_QUEUE", attributes: .concurrent)) {
        self.logger = logger
        logger.delegate = delegate
        self.config = config
        self.delegate = delegate
        self.socket = socket
        self.queue = queue
        self.socket.delegate = self
    }

    public func recreate() {
        socket = type(of: socket).init(url: URL(string: config.socketAddress)!, timeout: config.connectionRetryInterval, logger: logger)
        isDisposed = false
    }

    /// Connect to async server.
    public func connect() {
        onStatusChanged(.connecting)
        socket.connect()
    }

    /// Reconnect when you want to connect again.
    public func reconnect() {
        connect()
    }

    public func onConnected(_: WebSocketProvider) {
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            onStatusChanged(.connected)
            socketConnected()
            checkConnectionTimer()
            prepareTimerForNextPing()
        }
    }

    public func onDisconnected(_: WebSocketProvider, _ error: Error?) {
        queue.asyncWork {  [weak self] in
            guard let self = self else { return }
            stateModel.isDeviceRegistered = false
            logger.log(message: "Disconnected with error:\(String(describing: error))", persist: false, type: .internalLog)
            onStatusChanged(.closed, error)
            stopCheckConnectionTimer()
            stopPingTimer()
            restartReconnectTimer()
        }
    }

    public func onReceivedError(_ error: Error?) {
        queue.asyncWork {  [weak self] in
            guard let self = self else { return }
            logger.log(message: "Received Error:\(String(describing: error))", persist: true, type: .internalLog, userInfo: loggerUserInfo)
            if stateModel.lastMessageRCVDate == nil {
                // This block means if the user doesn't access the internet and try to connect for the first time he must get a CLOSE state
                onStatusChanged(.closed, error)
            }
            stopCheckConnectionTimer()
            stopPingTimer()
            restartReconnectTimer()
        }
    }

    public func onReceivedData(_: WebSocketProvider, didReceive data: Data) {
        syncQueue.async { [weak self] in
            self?.messageReceived(data: data)
        }
    }

    private func prepareTimerForNextPing() {
        if pingTimer == nil {
            queue.asyncWork { [weak self] in
                guard let self = self else { return }
                pingTimer = Timer.scheduledTimer(withTimeInterval: config.pingInterval, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    sendPing()
                }
                RunLoop.current.run()
            }
        }
    }

    private func socketConnected() {
        stateModel.retryCount = 0
        stopReconnectTimer()
    }

    private func restartReconnectTimer() {
        if config.reconnectOnClose == true && reconnectTimer == nil {
            queue.asyncWork { [weak self] in
                guard let self = self else { return }
                reconnectTimer = Timer.scheduledTimer(withTimeInterval: config.connectionRetryInterval, repeats: true) { [weak self] _ in
                    if self?.isDisposed == false && self?.stateModel.socketState != .connected {
                        self?.tryReconnect()
                    }
                }
                RunLoop.current.run()
            }
        }
    }

    public func stopPingTimer() {
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            pingTimer?.invalidateTimer()
            pingTimer = nil
        }
    }

    public func stopReconnectTimer() {
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            reconnectTimer?.invalidateTimer()
            reconnectTimer = nil
        }
    }

    public func stopCheckConnectionTimer() {
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            connectionStatusTimer?.invalidateTimer()
            connectionStatusTimer = nil
        }
    }

    private func tryReconnect() {
        if stateModel.retryCount < config.reconnectCount {
            stateModel.retryCount += 1
            logger.log(message: "Try reconnect for \(stateModel.retryCount) times", persist: false, type: .internalLog)
            reconnect()
        } else {
            logger.log(message: "Failed to reconnect after \(config.reconnectCount) tries", persist: false, type: .internalLog)
            reconnectTimer?.invalidateTimer()
        }
    }

    /// Send data to server.
    ///
    ///  The message will send only if the socket state is in ``AsyncSocketState/asyncReady`` mode unless the message will be queued and after connecting to the server it sends those messages.
    /// - Parameters:
    ///   - message: A sendable async message, at end it will convert to ``AsyncMessage`` and then data.
    ///   - type: The type of async message. For most of the times it will use ``AsyncMessageTypes/message``.
    public func send(message: SendAsyncMessageVO, type: AsyncMessageTypes = .message) {
        guard let data = try? JSONEncoder.instance.encode(message) else { return }
        let asyncSendMessage = AsyncMessage(content: data.utf8String, type: type)
        let asyncMessageData = try? JSONEncoder.instance.encode(asyncSendMessage)
        if stateModel.socketState == .asyncReady {
            guard let asyncMessageData = asyncMessageData, let string = String(data: asyncMessageData, encoding: .utf8) else { return }
            logger.logJSON(title: "Send message", jsonString: asyncSendMessage.string ?? "", persist: false, type: .sent)
            delegate?.asyncMessageSent(message: asyncMessageData, error: nil)
            socket.send(text: string)
        } else {
            delegate?.asyncMessageSent(message: nil, error: AsyncError(code: .socketIsNotConnected))
        }
    }

    /// Notify and close the current connection.
    public func closeConnection() {
        onStatusChanged(.closed)
        socket.closeConnection()
    }

    private func registerDevice() {
        if let deviceId = stateModel.deviceId {
            let peerId = stateModel.peerId
            let shouldRegister = peerId == nil
            let register: RegisterDevice = shouldRegister ? .init(renew: true, appId: config.appId, deviceId: deviceId) : .init(refresh: true, appId: config.appId, deviceId: deviceId)
            if let data = try? JSONEncoder.instance.encode(register) {
                sendInternalData(type: .deviceRegister, data: data)
            }
        }
    }

    private func registerServer() {
        let register = RegisterServer(name: config.peerName)
        if let data = try? JSONEncoder.instance.encode(register) {
            sendInternalData(type: .serverRegister, data: data)
        }
    }

    private func sendACK(asyncMessage: AsyncMessage) {
        if let id = asyncMessage.id {
            let messageACK = MessageACK(messageId: id)
            if let data = try? JSONEncoder.instance.encode(messageACK) {
                sendInternalData(type: .ack, data: data)
            }
        }
    }

    func sendPing() {
        sendInternalData(type: .ping, data: nil)
    }

    func sendInternalData(type: AsyncMessageTypes, data: Data?) {
        let asyncSendMessage = AsyncMessage(content: data?.utf8String, type: type)
        let asyncMessageData = try? JSONEncoder.instance.encode(asyncSendMessage)
        logger.logJSON(title: "Send an internal message", jsonString: asyncSendMessage.string ?? "", persist: false, type: .sent, userInfo: ["\(type.rawValue)": asyncSendMessage.string ?? ""])
        guard let asyncMessageData = asyncMessageData, let string = String(data: asyncMessageData, encoding: .utf8) else { return }
        socket.send(text: string)
    }

    private func checkConnectionTimer() {
        if connectionStatusTimer == nil {
            queue.asyncWork { [weak self] in
                guard let self = self else { return }
                connectionStatusTimer = Timer.scheduledTimer(withTimeInterval: config.connectionCheckTimeout, repeats: true) { [weak self] _ in
                    self?.onCheckConnectionTimer()
                }
                RunLoop.current.run()
            }
        }
    }

    private func onCheckConnectionTimer() {
        let lastMSG = stateModel.lastMessageRCVDate?.timeIntervalSince1970 ?? (Date().timeIntervalSince1970 - config.connectionCheckTimeout)
        if lastMSG + config.connectionCheckTimeout < Date().timeIntervalSince1970 {
            logger.log(message: "Check connection status: Closed", persist: false, type: .internalLog)
            onStatusChanged(.closed)
            stopCheckConnectionTimer()
            restartReconnectTimer()
        } else {
            logger.log(message: "Check connection status: Alive", persist: false, type: .internalLog)
        }
    }

    /// Dispose and try to disconnect immediately and release all related objects.
    public func disposeObject() {
        stopCheckConnectionTimer()
        stopPingTimer()
        stopReconnectTimer()
        closeConnection()
        delegate = nil
        isDisposed = true
    }
}

// async on Message Received Handler
extension Async {
    private func messageReceived(data: Data) {
        guard let asyncMessage = try? JSONDecoder.instance.decode(AsyncMessage.self, from: data) else {
            logger.log(message: "Can not decode the data", persist: false, type: .internalLog)
            return
        }
        logger.logJSON(title: "On Receive Message", jsonString: asyncMessage.string ?? "", persist: false, type: .received)
        prepareTimerForNextPing()
        stateModel.setLastMessageReceiveDate()
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
        case .peerRemoved, .registerQueue, .notRegistered, .errorMessage:
            break
        case .none:
            logger.createLog(message: "UNKOWN type received", persist: true, level: .error, type: .internalLog, userInfo: loggerUserInfo)
        }
    }

    private func onPingMessage(asyncMessage: AsyncMessage) {
        if asyncMessage.content != nil {
            if stateModel.deviceId == nil {
                stateModel.setDeviceId(deviceId: asyncMessage.content)
            }
            registerDevice()
        }
    }

    private func onDeviceRegisteredMessage(asyncMessage: AsyncMessage) {
        let oldPeerId = stateModel.peerId
        if let peerIdString = asyncMessage.content {
            stateModel.setPeerId(peerId: Int(peerIdString))
        }

        if stateModel.isServerRegistered == true, stateModel.peerId == oldPeerId {
            onStatusChanged(.asyncReady)
        } else {
            registerServer()
        }

        /// We should set this property after checking if current state is registered or not.
        stateModel.isDeviceRegistered = true
    }

    private func onServerRegisteredMessage(asyncMessage: AsyncMessage) {
        if asyncMessage.senderName == config.peerName {
            stateModel.isServerRegistered = true
            onStatusChanged(.asyncReady)
        } else {
            registerServer()
        }
    }

    func onStatusChanged(_ status: AsyncSocketState, _ error: Error? = nil) {
        stateModel.setSocketState(socketState: status)
        logger.log(message: "Connection State Changed to: \(status)", persist: false, type: .internalLog)
        delegate?.asyncStateChanged(asyncState: status, error: error == nil ? nil : .init(rawError: error))
    }
}