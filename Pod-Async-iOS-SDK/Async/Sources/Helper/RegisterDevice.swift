//
//  RegisterDevice.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

/// A struct of the request/response for registering the device with the server.
struct RegisterDevice : Codable{

    /// A boolean is set to true if the peerId has never set before.
    var renew          : Bool?

    /// A boolean is set to true if the peerId has set before and has a value.
    var refresh        : Bool?

    /// This `appId` will be gained by the configuration.
    var appId          : String

    /// Device id.
    var deviceId       : String

    /// A boolean is set to true if the peerId has been set before and has a value, otherwise, the other initializer will be used with the refresh.
    public init(renew: Bool, appId: String, deviceId: String) {
        self.renew      = renew
        self.refresh    = nil
        self.appId      = appId
        self.deviceId   = deviceId
    }

    ///A boolean is set to true if the peerId has been set before and has a value, otherwise, the other initializer will be used with renewing.
    public init(refresh: Bool, appId: String, deviceId: String) {
        self.renew      = nil
        self.refresh    = refresh
        self.appId      = appId
        self.deviceId   = deviceId
    }
}
