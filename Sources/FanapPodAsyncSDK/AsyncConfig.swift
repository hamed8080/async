//
// AsyncConfig.swift
// Copyright (c) 2022 FanapPodAsyncSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

/// Configuration data that needs to prepare to use SDK.
///
/// To work with SDK this struct must be passed to ``Async`` initializer.
///
/// ```swift
///  let asyncConfig = AsyncConfig(socketAddress: "192.168.1.1", serverName: "Chat")
/// ```
public struct AsyncConfig {
    public var socketAddress: String
    public var serverName: String
    public var deviceId: String = UUID().uuidString
    public var appId: String = "POD-Chat"
    public var peerId: Int?
    public var messageTtl: Int = 10000
    public var connectionRetryInterval: TimeInterval = 5
    public var connectionCheckTimeout: TimeInterval = 20
    public var reconnectCount: Int = 5
    public var reconnectOnClose: Bool = false
    public var isDebuggingLogEnabled: Bool = false

    /// Configuration data that needs to prepare to use SDK.
    ///
    /// - Parameters:
    ///   - socketAddress: The server address of socket.
    ///   - serverName: Server name of Async Server.
    ///   - deviceId: Device id of the current device if you don't pass an id it generates an id with UUID.
    ///   - appId: The id of application that registered in server.
    ///   - peerId: Id of peer.
    ///   - messageTtl: Message TTL.
    ///   - connectionRetryInterval: The interval between fails to connect tries.
    ///   - connectionCheckTimeout: Time in seconds for checking connection status and try if disconnected or informing you through the delegate.
    ///   - reconnectCount: The amount of times when socket fail or disconnect if reconnectOnClose is enabled
    ///   - reconnectOnClose: If it is true it tries to connect again depending on how many times you've set reconnectCount.
    ///   - isDebuggingLogEnabled: If debugging is set true in the console you'll see logs for messages that send and receive and also what's happening when the socket state changes.
    public init(socketAddress: String,
                serverName: String,
                deviceId: String = UUID().uuidString,
                appId: String = "POD-Chat",
                peerId: Int? = nil,
                messageTtl: Int = 10000,
                connectionRetryInterval: TimeInterval = 5,
                connectionCheckTimeout: TimeInterval = 20,
                reconnectCount: Int = 5,
                reconnectOnClose: Bool = false,
                isDebuggingLogEnabled: Bool = false)
    {
        self.socketAddress = socketAddress
        self.serverName = serverName
        self.deviceId = deviceId
        self.appId = appId
        self.peerId = peerId
        self.messageTtl = messageTtl
        self.connectionRetryInterval = connectionRetryInterval
        self.connectionCheckTimeout = connectionCheckTimeout
        self.reconnectCount = reconnectCount
        self.reconnectOnClose = reconnectOnClose
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
    }

    /// Configuration data that needs to prepare to use SDK.
    ///
    /// - Parameters:
    ///   - socketAddress: The server address of socket.
    ///   - serverName: Server name of Async Server.
    ///   - appId: The id of application that registered in server.
    public init(socketAddress: String, serverName: String, appId: String) {
        self.socketAddress = socketAddress
        self.serverName = serverName
        self.appId = appId
    }
}
