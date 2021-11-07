//
//  NewAsync.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation
public final class NewAsync : WebSocketProviderDelegate{
  
    public var delegate                               : NewAsyncDelegate?
    private (set) var config                          : AsyncConfig
    private (set) var socket                          : WebSocketProvider?
    private (set) var asyncStateModel                 : AsyncStateModel        = AsyncStateModel()
    private var reconnectTimer                        : Timer?                 = nil
    private var pingTimer                             : Timer?                 = nil
    private var connectionStatusTimer                 : Timer?                 = nil
    private var logger                                : Logger
    
    public init(config:AsyncConfig , delegate:NewAsyncDelegate? = nil){
        self.config   = config
        self.delegate = delegate
        self.logger   = Logger(isDebuggingLogEnabled: config.isDebuggingLogEnabled)
        checkConnectionTimer()
    }
    
    public func createSocket(){
        setSocketState(socketState: .CONNECTING)
        if #available(iOS 13.0, *) {
            socket = NativeWebSocketProvider(url: URL(string: config.socketAddress)! ,timeout:config.connectionRetryInterval, logger: logger)
        }else{
            socket = StarScreamWebSocketProvider(url: URL(string: config.socketAddress)!,timeout:config.connectionRetryInterval, logger: logger)
        }
        socket?.delegate = self
        socket?.connect()
    }
    
    public func reconnect(){
        setSocketState(socketState: .CONNECTING)
        socket?.connect()
    }
    
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        setSocketState(socketState: .CONNECTED)
        socketConnected()
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider, _ error:Error? ) {
        logger.log(title:"disconnected with error:\(String(describing: error))")
        setSocketState(socketState: .CLOSED , error: error)
        DispatchQueue.main.async {
            if self.config.reconnectOnClose == true{
                self.tryToReconnectToSocket()
            }
        }
    }
    
    func webSocketReceiveError(_ error: Error?) {
        logger.log(title:"received Error:\(String(describing: error))")
        if asyncStateModel.lastMessageRCVDate == nil{
            //This block means if the user doesn't access the internet and try to connect for the first time he must get a CLOSE state
            DispatchQueue.main.async {
                self.setSocketState(socketState: .CLOSED, error: error)
                self.tryToReconnectToSocket()
            }
        }
    }
    
    func webSocketDidReciveData(_ webSocket: WebSocketProvider, didReceive data: Data) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else{return}
            self.messageReceived(data: data)
        }
    }
    
    private func prepareTimerForNextPing(){
        self.pingTimer?.invalidate()
        self.pingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {[weak self] timer in
            guard let self = self else{return}
            self.sendPing()
        }
    }
    
    private func socketConnected(){
        asyncStateModel.retryCount = 0
        reconnectTimer = nil
    }
    
    private func tryToReconnectToSocket(){
        if config.reconnectOnClose == true && reconnectTimer == nil{
            reconnectTimer = Timer.scheduledTimer(withTimeInterval: config.connectionRetryInterval, repeats: true) { timer in
                if self.asyncStateModel.socketState == .CONNECTED || self.asyncStateModel.socketState == .ASYNC_READY {
                    timer.invalidate()
                    return
                }
                if self.asyncStateModel.retryCount < self.config.reconnectCount{
                    self.asyncStateModel.retryCount += 1
                    self.logger.log(title: "try reconnect for \(self.asyncStateModel.retryCount) times")
                    self.reconnect()
                }else{
                    self.logger.log(title: "failed to reconnect after \(self.config.reconnectCount) tries")
                    timer.invalidate()
                }
            }
        }
    }
        
    public func sendData(type:AsyncMessageTypes, data:Data?){
        let asyncSendMessage = NewAsyncMessage(content: data?.string() , type: type)
        let asyncMessageData = try? JSONEncoder().encode(asyncSendMessage)
        if asyncStateModel.socketState == .ASYNC_READY{
            logger.log(title: "send Message", jsonString: asyncSendMessage.string ?? "")
            guard let asyncMessageData = asyncMessageData , let string = String(data:asyncMessageData, encoding: .utf8) else{return}
            socket?.send(text: string)
            delegate?.asyncMessageSent(message: asyncMessageData)
        }else{
            addToQueue(asyncMessageData: asyncMessageData)
        }
    }
    
    private func addToQueue(asyncMessageData:Data?){
        if let asyncMessageData = asyncMessageData{
            logger.log(title: "message added to queue", jsonString: asyncMessageData.string ?? "")
            asyncStateModel.messageQueue.append(asyncMessageData)
        }
    }
    
    public func closeConnection(){
        setSocketState(socketState: .CLOSED)
        socket?.closeConnection()
    }
    
    private func registerDevice(){
        let register:RegisterDevice = asyncStateModel.peerId == nil ?
            .init(renew: true, appId: config.appId, deviceId: asyncStateModel.deviceId ?? "") :
            .init(refresh: true, appId: config.appId, deviceId: asyncStateModel.deviceId ?? "")
        
        if let data = try? JSONEncoder().encode(register){
            sendConnectionData(type: .DEVICE_REGISTER, data: data)
        }
    }
    
    private func registerServer(){
        let register = RegisterServer(name: config.serverName)
        if let data = try? JSONEncoder().encode(register){
            sendConnectionData(type: .SERVER_REGISTER, data: data)
        }
    }
    
    private func sendQueueMessages(){
        asyncStateModel.messageQueue.forEach { asyncMessageData in
            if asyncStateModel.socketState == .CONNECTED{
                logger.log(title: "pop and sending message from queue", jsonString: asyncMessageData.string() ?? "")
                socket?.send(data: asyncMessageData)
                DispatchQueue.main.async {
                    self.delegate?.asyncMessageSent(message: asyncMessageData)
                }
            }
        }
    }
    
    private func sendACK(asyncMessage: NewAsyncMessage) {
        if let id = asyncMessage.id{
            let messageACK = MessageACK(messageId: id)
            if let data = try? JSONEncoder().encode(messageACK){
                sendConnectionData(type: .ACK, data: data)
            }
        }
    }
    
    private func sendPing(){
        sendConnectionData(type: .PING,data: nil)
    }
    
    private func sendConnectionData(type:AsyncMessageTypes, data:Data?){
        let asyncSendMessage = NewAsyncMessage(content: data?.string() , type: type)
        let asyncMessageData = try? JSONEncoder().encode(asyncSendMessage)
        logger.log(title:"send Message", jsonString: asyncSendMessage.string ?? "")
        guard let asyncMessageData = asyncMessageData , let string = String(data:asyncMessageData, encoding: .utf8) else{return}
        socket?.send(text: string)
    }
    
    private func checkConnectionTimer(){
        connectionStatusTimer = Timer.scheduledTimer(withTimeInterval: config.connectionCheckTimeout, repeats: true, block: { [weak self] timer in
            guard let self = self else {return}
            if let lastMSG = self.asyncStateModel.lastMessageRCVDate , lastMSG.timeIntervalSince1970 + self.config.connectionCheckTimeout < Date().timeIntervalSince1970{
                self.setSocketState(socketState: .CLOSED, error: nil)
                self.tryToReconnectToSocket()
            }
        })
    }
    
    public func disposeObject(){
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

//async on Message Received Handler
extension NewAsync{
    
    private func messageReceived(data:Data){
        guard let asyncMessage = try? JSONDecoder().decode(NewAsyncMessage.self, from: data) else{
            logger.log(title:"can't decode data")
            return
        }
        logger.log(title:"on message", jsonString: asyncMessage.string ?? "")
        prepareTimerForNextPing()
        asyncStateModel.setLastMessageReceiveDate()
        switch  asyncMessage.type{
        case .PING:
            onPingMessage(asyncMessage: asyncMessage)
            break
        case .SERVER_REGISTER:
            onServerRegisteredMessage(asyncMessage: asyncMessage)
            break
        case .DEVICE_REGISTER:
            onDeviceRegisteredMessage(asyncMessage: asyncMessage)
            break
        case .MESSAGE:
            delegate?.asyncMessage(asyncMessage: asyncMessage)
            break
        case .MESSAGE_ACK_NEEDED , .MESSAGE_SENDER_ACK_NEEDED:
            sendACK(asyncMessage: asyncMessage)
            delegate?.asyncMessage(asyncMessage: asyncMessage)
            break
        case .ACK:
            delegate?.asyncMessage(asyncMessage: asyncMessage)
            break
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
    
    private func onPingMessage(asyncMessage:NewAsyncMessage){
        if asyncMessage.content != nil{
            if asyncStateModel.deviceId == nil{
                asyncStateModel.setDeviceId(deviceId: asyncMessage.content)
            }
            registerDevice()
        }
    }
    
    private func onDeviceRegisteredMessage(asyncMessage:NewAsyncMessage) {
        asyncStateModel.isDeviceRegistered = true
        let oldPeerId = asyncStateModel.peerId
        if let peerIdString = asyncMessage.content{
            asyncStateModel.setPeerId(peerId: Int(peerIdString))
        }
        
        if asyncStateModel.isServerRegistered == true && asyncStateModel.peerId == oldPeerId{
            setSocketState(socketState: .ASYNC_READY)
            sendQueueMessages()
        } else {
            registerServer()
        }
    }
    
    private func onServerRegisteredMessage(asyncMessage:NewAsyncMessage) {
        if asyncMessage.senderName == config.serverName {
            asyncStateModel.isServerRegistered = true
            setSocketState(socketState: .ASYNC_READY)
            sendQueueMessages()
        } else {
            registerServer()
        }
    }
    
    private func setSocketState(socketState:AsyncSocketState,error:Error? = nil){
        asyncStateModel.setSocketState(socketState: socketState)
        logger.log(title: "async state changed to:\(socketState)")
        DispatchQueue.main.async {
            self.delegate?.asyncStateChanged(asyncState: socketState, error: .init(rawError: error))
        }
    }
        
}
