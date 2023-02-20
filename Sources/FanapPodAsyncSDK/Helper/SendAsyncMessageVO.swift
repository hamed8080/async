//
// SendAsyncMessageVO.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/16/22

import Foundation

public struct SendAsyncMessageVO: Codable {
    public init(content: String, ttl: Int, peerName: String, priority: Int = 1, pushMsgType: AsyncMessageTypes? = nil, uniqueId: String? = nil) {
        self.content = content
        self.ttl = ttl
        self.peerName = peerName
        self.priority = priority
        self.pushMsgType = pushMsgType
        self.uniqueId = uniqueId
    }

    public let content: String
    public let ttl: Int
    public let peerName: String
    public private(set) var priority: Int = 1
    public private(set) var pushMsgType: AsyncMessageTypes?
    public let uniqueId: String?
}
