//
// NewAsync.swift
// Copyright (c) 2022 FanapPodAsyncSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

private protocol AsyncProtocol {
    var delegate: AsyncDelegate? { get }
    var socket: WebSocketProvider { get }
    var pingTimer: Timer? { get set }
    var reconnectTimer: Timer? { get set }
    var connectionStatusTimer: Timer? { get set }
    var logger: Logger { get }
    var config: AsyncConfig { get }
    var queue: DispatchQueue { get }

    /// A boolean that indicates the device is successfully registered with the async server.
    var isServerRegistered: Bool { get set }

    /// A boolean that indicates the device is successfully registered.
    var isDeviceRegistered: Bool { get set }

    /// A queue that contains a list of messages that need to be sent in the order of the date they have been added.
    var messageQueue: [Data] { get set }

    /// The number of retries that have happened to connect to the async server.
    var retryCount: Int { get set }

    /// The peerId of, which will be filled after the device is registered.
    var peerId: Int? { get set }

    /// The state of the current socket.
    var socketState: AsyncSocketState { get set }

    /// The device id, it'll be set after the device is registered.
    var deviceId: String? { get set }

    /// The last message receive-date to track ping intervals.
    var lastMessageRCVDate: Date? { get set }

    init(config: AsyncConfig, delegate: AsyncDelegate?, resposneQueue: DispatchQueue)
    func create()
    func connect()
    func send(type: AsyncMessageTypes, data: Data, queueable: Bool)
    func reconnect()
    func onStatusChanged(_ status: AsyncSocketState, _ error: Error?)
    func onConnect()
    func onDisconnect()
    func disposeObject()
    func sendPing()
    func onPingNotReceived()
    func addToQueue(data: Data)
    func sendQueues()
}

// class NewAsync: AsyncProtocol {
//
// }
//
// extension NewAsync: WebSocketProviderDelegate {
//
// }
