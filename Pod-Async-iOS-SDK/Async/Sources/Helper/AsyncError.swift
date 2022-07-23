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

/// When an error happen in the server or in your request you will receive an error this type.
public struct AsyncError{

    /// Error code. it can be undifined.
    public var code     : AsyncErrorCodes    = .UNDEFINED

    /// The message that will give you more information about the error.
    public var message  : String?            = nil

    /// The user info of the error.
    public var userInfo : [String:Any]?      = nil

    ///Raw error so you could diagnose the error in a way you prefer.
    public var rawError : Error?             = nil

    /// Initializer of an error.
    /// - Parameters:
    ///   - code: Error code. it can be undifined.
    ///   - message: The message that will give you more information about the error.
    ///   - userInfo: The user info of the error.
    ///   - rawError: Raw error so you could diagnose the error in a way you prefer.
    public init(code: AsyncErrorCodes = .UNDEFINED, message: String? = nil, userInfo: [String : Any]? = nil, rawError:Error? = nil) {
        self.code       = code
        self.message    = message
        self.userInfo   = userInfo
        self.rawError   = rawError
    }
    
}
