//
//  AsyncConfig.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

public struct AsyncConfig{
    
    var socketAddress              : String
    var serverName                 : String
    var deviceId                   : String             = UUID().uuidString
    var appId                      : String             = "POD-Chat"
    var peerId                     : Int?
    var messageTtl                 : Int?
    var connectionRetryInterval    : TimeInterval       = 5
    var reconnectCount             : Int                = 5
    var reconnectOnClose           : Bool               = false
    var isDebuggingLogEnabled      : Bool               = false
    
    public init(socketAddress             : String,
                  serverName                : String,
                  deviceId                  : String                = UUID().uuidString,
                  appId                     : String                = "POD-Chat",
                  peerId                    : Int?                  = nil,
                  messageTtl                : Int?                  = nil,
                  connectionRetryInterval   : TimeInterval          = 5,
                  reconnectCount            : Int                   = 5,
                  reconnectOnClose          : Bool                  = false,
                  isDebuggingLogEnabled     : Bool                  = false
    ) {
        
        self.socketAddress              = socketAddress
        self.serverName                 = serverName
        self.deviceId                   = deviceId
        self.appId                      = appId
        self.peerId                     = peerId
        self.messageTtl                 = messageTtl
        self.connectionRetryInterval    = connectionRetryInterval
        self.reconnectCount             = reconnectCount
        self.reconnectOnClose           = reconnectOnClose
        self.isDebuggingLogEnabled      = isDebuggingLogEnabled
    }
    
}
