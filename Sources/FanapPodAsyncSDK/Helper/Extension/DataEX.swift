//
// DataEX.swift
// Copyright (c) 2022 FanapPodAsyncSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

extension Data {
    /// A converter extension that converts data to string with UTF-8.
    func string() -> String? {
        String(data: self, encoding: .utf8)
    }
}
