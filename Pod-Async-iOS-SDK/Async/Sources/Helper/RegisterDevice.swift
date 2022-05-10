//
//  RegisterDevice.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation
struct RegisterDevice : Codable{
  
    var renew          : Bool?
    var refresh        : Bool?
    var appId          : String
    var deviceId       : String
    
    public init(renew: Bool, appId: String, deviceId: String) {
        self.renew      = renew
        self.refresh    = nil
        self.appId      = appId
        self.deviceId   = deviceId
    }
    
    public init(refresh: Bool, appId: String, deviceId: String) {
        self.renew      = nil
        self.refresh    = refresh
        self.appId      = appId
        self.deviceId   = deviceId
    }
}
