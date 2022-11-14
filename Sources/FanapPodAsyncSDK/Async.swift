//
//  Async.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation



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
        self.config = config
        self.delegate = delegate
        self.logger = Logger(isDebuggingLogEnabled: config.isDebuggingLogEnabled)
        checkConnectionTimer()
    }

    /// Create and connect to the socket for the first tiem and notify the connection state if delegate is setted.
    ///
    /// It'll connect through Apple native socket in iOS 13 and above, on the other hand, it'll connect through StarScream in older devices.
    public func createSocket() {
        setSocketState(socketState: .CONNECTING)
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
        setSocketState(socketState: .CONNECTING)
        socket?.connect()
    }

    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        setSocketState(socketState: .CONNECTED)
        socketConnected()
    }

    func webSocketDidDisconnect(_ webSocket: WebSocketProvider, _ error: Error?) {
        logger.log(title: "disconnected with error:\(String(describing: error))")
        setSocketState(socketState: .CLOSED, error: error)
        DispatchQueue.main.async { [weak self] in
            if self?.config.reconnectOnClose == true {
                self?.tryToReconnectToSocket()
            }
        }
    }

    func webSocketReceiveError(_ error: Error?) {
        logger.log(title: "received Error:\(String(describing: error))")
        if asyncStateModel.lastMessageRCVDate == nil {
            // This block means if the user doesn't access the internet and try to connect for the first time he must get a CLOSE state
            DispatchQueue.main.async { [weak self] in
                self?.setSocketState(socketState: .CLOSED, error: error)
                self?.tryToReconnectToSocket()
            }
        }
    }

    func webSocketDidReciveData(_ webSocket: WebSocketProvider, didReceive data: Data) {
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
                if self.asyncStateModel.socketState == .CONNECTED || self.asyncStateModel.socketState == .ASYNC_READY {
                    timer.invalidate()
                    return
                }
                if self.asyncStateModel.retryCount < self.config.reconnectCount {
                    self.asyncStateModel.retryCount += 1
                    self.logger.log(title: "try reconnect for \(self.asyncStateModel.retryCount) times")
                    self.reconnect()
                } else {
                    self.logger.log(title: "failed to reconnect after \(self.config.reconnectCount) tries")
                    timer.invalidate()
                }
            }
        }
    }

    /// Send data to serevr.
    ///
    ///  The message will send only if the socket state is in ``AsyncSocketState/ASYNC_READY`` mode unless the message will be queued and after connecting to the server it sends those messages.
    /// - Parameters:
    ///   - type: The type of async message. For most of the times it will use ``AsyncMessageTypes/MESSAGE``.
    ///   - data: If you pass nil nothing happend here.
    public func sendData(type: AsyncMessageTypes, data: Data?) {
        let asyncSendMessage = AsyncMessage(content: data?.string(), type: type)
        let asyncMessageData = try? JSONEncoder().encode(asyncSendMessage)
        if asyncStateModel.socketState == .ASYNC_READY {
            logger.log(title: "send Message", jsonString: asyncSendMessage.string ?? "")
            guard let asyncMessageData = asyncMessageData, let string = String(data: asyncMessageData, encoding: .utf8) else { return }
            socket?.send(text: string)
            delegate?.asyncMessageSent(message: asyncMessageData)
        } else {
            addToQueue(asyncMessageData: asyncMessageData)
        }
    }

    private func addToQueue(asyncMessageData: Data?) {
        if let asyncMessageData = asyncMessageData {
            logger.log(title: "message added to queue", jsonString: asyncMessageData.string ?? "")
            asyncStateModel.messageQueue.append(asyncMessageData)
        }
    }

    /// Notify and close the current connection.
    public func closeConnection() {
        setSocketState(socketState: .CLOSED)
        socket?.closeConnection()
    }

    private func registerDevice() {
        let register: RegisterDevice = asyncStateModel.peerId == nil ?
            .init(renew: true, appId: config.appId, deviceId: asyncStateModel.deviceId ?? "") :
            .init(refresh: true, appId: config.appId, deviceId: asyncStateModel.deviceId ?? "")

        if let data = try? JSONEncoder().encode(register) {
            sendConnectionData(type: .DEVICE_REGISTER, data: data)
        }
    }

    private func registerServer() {
        let register = RegisterServer(name: config.serverName)
        if let data = try? JSONEncoder().encode(register) {
            sendConnectionData(type: .SERVER_REGISTER, data: data)
        }
    }

    private func sendQueueMessages() {
        asyncStateModel.messageQueue.forEach { asyncMessageData in
            if asyncStateModel.socketState == .CONNECTED {
                logger.log(title: "pop and sending message from queue", jsonString: asyncMessageData.string() ?? "")
                socket?.send(data: asyncMessageData)
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.asyncMessageSent(message: asyncMessageData)
                }
            }
        }
    }

    private func sendACK(asyncMessage: AsyncMessage) {
        if let id = asyncMessage.id {
            let messageACK = MessageACK(messageId: id)
            if let data = try? JSONEncoder().encode(messageACK) {
                sendConnectionData(type: .ACK, data: data)
            }
        }
    }

    private func sendPing() {
        sendConnectionData(type: .PING, data: nil)
    }

    private func sendConnectionData(type: AsyncMessageTypes, data: Data?) {
        let asyncSendMessage = AsyncMessage(content: data?.string(), type: type)
        let asyncMessageData = try? JSONEncoder().encode(asyncSendMessage)
        logger.log(title: "send Message", jsonString: asyncSendMessage.string ?? "")
        guard let asyncMessageData = asyncMessageData, let string = String(data: asyncMessageData, encoding: .utf8) else { return }
        socket?.send(text: string)
    }

    private func checkConnectionTimer() {
        connectionStatusTimer?.invalidate()
        connectionStatusTimer = nil
        connectionStatusTimer = Timer.scheduledTimer(withTimeInterval: config.connectionCheckTimeout, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            if let lastMSG = self.asyncStateModel.lastMessageRCVDate, lastMSG.timeIntervalSince1970 + self.config.connectionCheckTimeout < Date().timeIntervalSince1970 {
                self.setSocketState(socketState: .CLOSED, error: nil)
                self.tryToReconnectToSocket()
            }
        })
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
        guard let asyncMessage = try? JSONDecoder().decode(AsyncMessage.self, from: data) else {
            logger.log(title: "can't decode data")
            return
        }
        logger.log(title: "on message", jsonString: asyncMessage.string ?? "")
        prepareTimerForNextPing()
        asyncStateModel.setLastMessageReceiveDate()
        switch asyncMessage.type {
        case .PING:
            onPingMessage(asyncMessage: asyncMessage)
        case .SERVER_REGISTER:
            onServerRegisteredMessage(asyncMessage: asyncMessage)
        case .DEVICE_REGISTER:
            onDeviceRegisteredMessage(asyncMessage: asyncMessage)
        case .MESSAGE:
            delegate?.asyncMessage(asyncMessage: asyncMessage)
        case .MESSAGE_ACK_NEEDED, .MESSAGE_SENDER_ACK_NEEDED:
            sendACK(asyncMessage: asyncMessage)
            delegate?.asyncMessage(asyncMessage: asyncMessage)
        case .ACK:
            delegate?.asyncMessage(asyncMessage: asyncMessage)
        case .GET_REGISTERED_PEERS:
            break
        case .PEER_REMOVED:
            break
        case .REGISTER_QUEUE:
            break
        case .NOT_REGISTERED:
            break
        case .ERROR_MESSAGE:
            break
        case .none:
            logger.log(title: "can't decode data")
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
            setSocketState(socketState: .ASYNC_READY)
            sendQueueMessages()
        } else {
            registerServer()
        }
    }

    private func onServerRegisteredMessage(asyncMessage: AsyncMessage) {
        if asyncMessage.senderName == config.serverName {
            asyncStateModel.isServerRegistered = true
            setSocketState(socketState: .ASYNC_READY)
            sendQueueMessages()
        } else {
            registerServer()
        }
    }

    private func setSocketState(socketState: AsyncSocketState, error: Error? = nil) {
        asyncStateModel.setSocketState(socketState: socketState)
        logger.log(title: "async state changed to:\(socketState)")
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.asyncStateChanged(asyncState: socketState, error: error == nil ? nil : .init(rawError: error))
        }
    }
}
