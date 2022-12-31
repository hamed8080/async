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
    public private(set) var socketAddress: String
    public private(set) var serverName: String
    public private(set) var deviceId: String = UUID().uuidString
    public private(set) var appId: String = "POD-Chat"
    public private(set) var peerId: Int?
    public private(set) var messageTtl: Int = 10000
    public private(set) var connectionRetryInterval: TimeInterval = 5
    public private(set) var connectionCheckTimeout: TimeInterval = 20
    public private(set) var reconnectCount: Int = 5
    public private(set) var reconnectOnClose: Bool = false
    public private(set) var isDebuggingLogEnabled: Bool = false

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

    public mutating func updateDeviceId(_ deviceId: String) {
        self.deviceId = deviceId
    }
}

public class AsyncConfigBuilder {
    private(set) var socketAddress: String = ""
    private(set) var serverName: String = ""
    private(set) var deviceId: String = UUID().uuidString
    private(set) var appId: String = "POD-Chat"
    private(set) var peerId: Int?
    private(set) var messageTtl: Int = 10000
    private(set) var connectionRetryInterval: TimeInterval = 5
    private(set) var connectionCheckTimeout: TimeInterval = 20
    private(set) var reconnectCount: Int = 5
    private(set) var reconnectOnClose: Bool = false
    private(set) var isDebuggingLogEnabled: Bool = false
    public init() {}

    @discardableResult
    public func socketAddress(_ socketAddress: String) -> AsyncConfigBuilder {
        self.socketAddress = socketAddress
        return self
    }

    @discardableResult
    public func serverName(_ serverName: String) -> AsyncConfigBuilder {
        self.serverName = serverName
        return self
    }

    @discardableResult
    public func deviceId(_ deviceId: String) -> AsyncConfigBuilder {
        self.deviceId = deviceId
        return self
    }

    @discardableResult
    public func appId(_ appId: String) -> AsyncConfigBuilder {
        self.appId = appId
        return self
    }

    @discardableResult
    public func peerId(_ peerId: Int?) -> AsyncConfigBuilder {
        self.peerId = peerId
        return self
    }

    @discardableResult
    public func messageTtl(_ messageTtl: Int) -> AsyncConfigBuilder {
        self.messageTtl = messageTtl
        return self
    }

    @discardableResult
    public func connectionRetryInterval(_ connectionRetryInterval: TimeInterval) -> AsyncConfigBuilder {
        self.connectionRetryInterval = connectionRetryInterval
        return self
    }

    @discardableResult
    public func connectionCheckTimeout(_ connectionCheckTimeout: TimeInterval) -> AsyncConfigBuilder {
        self.connectionCheckTimeout = connectionCheckTimeout
        return self
    }

    @discardableResult
    public func reconnectCount(_ reconnectCount: Int) -> AsyncConfigBuilder {
        self.reconnectCount = reconnectCount
        return self
    }

    @discardableResult
    public func reconnectOnClose(_ reconnectOnClose: Bool) -> AsyncConfigBuilder {
        self.reconnectOnClose = reconnectOnClose
        return self
    }

    @discardableResult
    public func isDebuggingLogEnabled(_ isDebuggingLogEnabled: Bool) -> AsyncConfigBuilder {
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
        return self
    }

    public func build() -> AsyncConfig {
        AsyncConfig(socketAddress: socketAddress,
                    serverName: serverName,
                    deviceId: deviceId,
                    appId: appId,
                    peerId: peerId,
                    messageTtl: messageTtl,
                    connectionRetryInterval: connectionRetryInterval,
                    connectionCheckTimeout: connectionCheckTimeout,
                    reconnectCount: reconnectCount,
                    reconnectOnClose: reconnectOnClose,
                    isDebuggingLogEnabled: isDebuggingLogEnabled)
    }
}
