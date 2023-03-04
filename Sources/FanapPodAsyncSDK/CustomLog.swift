//
// CustomLog.swift
// Copyright (c) 2022 FanapPodAsyncSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

protocol LoggerProtocol {
    init(logger: LoggerProtocol)
    func log()
}

protocol ConsoleLogger: LoggerProtocol {}

protocol FileLogger: LoggerProtocol {}

class NewLogger: LoggerProtocol {
    required init(logger _: LoggerProtocol) {}
    func log() {}
}

class Logger {
    private let sdkName = "ASYNC_SDK: "
    private var isDebuggingLogEnabled: Bool

    init(isDebuggingLogEnabled: Bool) {
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
    }

    func log(title: String? = nil, jsonString: String? = nil) {
        if isDebuggingLogEnabled {
            if let title = title {
                print(sdkName + title)
            }
            if let jsonString = jsonString {
                print("\(jsonString.preetyJsonString())")
            }
            print("\n")
        }
    }
}
