//
//  AsyncStateModel.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/23/21.
//

import Foundation

/// This struct only manages the state of the connection and persists all values that need for the async state.
struct AsyncStateModel{

    /// A boolean that indicates the device is successfully registered with the async server.
    var isServerRegistered              : Bool                   = false

    /// A boolean that indicates the device is successfully registered.
    var isDeviceRegistered              : Bool                   = false

    /// A queue that contains a list of messages that need to be sent in the order of the date they have been added.
    var messageQueue                    : [Data]                 = []

    /// The number of retries that have happened to connect to the async server.
    var retryCount                      : Int                    = 0

    /// The peerId of, which will be filled after the device is registered.
    private (set) var peerId            : Int?                   = nil

    /// The state of the current socket.
    private (set) var socketState       : AsyncSocketState       = .CLOSED

    /// The device id, it'll be set after the device is registered.
    private (set) var deviceId          : String?                = nil

    /// The last message receive-date to track ping intervals.
    private (set) var lastMessageRCVDate: Date?                  = nil
    
    /// Setter for the state of the connection.
    mutating func setSocketState(socketState:AsyncSocketState){
        self.socketState = socketState
    }

    /// Setter for the deviceId.
    mutating func setDeviceId(deviceId:String?){
        self.deviceId = deviceId
    }

    /// Setter for the peerId.
    mutating func setPeerId(peerId:Int?){
        self.peerId = peerId
    }

    /// Updater for the last message date received.
    mutating func setLastMessageReceiveDate(){
        self.lastMessageRCVDate = Date()
    }
}
