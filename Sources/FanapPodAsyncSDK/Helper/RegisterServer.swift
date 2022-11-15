//
// RegisterServer.swift
// Copyright (c) 2022 FanapPodAsyncSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
struct RegisterServer: Codable {
    /// The name of the server.
    var name: String

    /// The name of the server.
    /// - Parameter name: The server name.
    public init(name: String) {
        self.name = name
    }
}
