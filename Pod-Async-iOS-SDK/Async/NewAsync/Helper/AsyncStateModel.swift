//
//  AsyncStateModel.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/23/21.
//

import Foundation
struct AsyncStateModel{
    
    var isServerRegistered              : Bool                   = false    
    var isDeviceRegistered              : Bool                   = false
    var messageQueue                    : [Data]                 = []
    var retryCount                      : Int                    = 0
    private (set) var peerId            : Int?                   = nil
    private (set) var socketState       : AsyncSocketState       = .CLOSED
    private (set) var deviceId          : String?                = nil
    private (set) var lastMessageRCVDate: Date?                  = nil
    
    
    mutating func setSocketState(socketState:AsyncSocketState){
        self.socketState = socketState
    }
    
    mutating func setDeviceId(deviceId:String?){
        self.deviceId = deviceId
    }
    
    mutating func setPeerId(peerId:Int?){
        self.peerId = peerId
    }
    
    mutating func setLastMessageReceiveDate(){
        self.lastMessageRCVDate = Date()
    }
}
