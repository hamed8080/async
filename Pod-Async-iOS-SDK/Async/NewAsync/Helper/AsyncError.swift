//
//  AsyncError.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/23/21.
//

import Foundation

public enum AsyncErrorCodes:Int{
    case ERROR_PING = 4000
    
    case UNDEFINED
}

public struct AsyncError{

    public var code     : AsyncErrorCodes    = .UNDEFINED
    public var message  : String?            = nil
    public var userInfo : [String:Any]?      = nil
    public var rawError : Error?             = nil
    
    public init(code: AsyncErrorCodes = .UNDEFINED, message: String? = nil, userInfo: [String : Any]? = nil, rawError:Error? = nil) {
        self.code       = code
        self.message    = message
        self.userInfo   = userInfo
        self.rawError   = rawError
    }
    
}
