//
//  AsyncMessageTypes.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

public enum AsyncMessageTypes : Int , Codable{
    
    case PING                       = 0
    case SERVER_REGISTER            = 1
    case DEVICE_REGISTER            = 2
    case MESSAGE                    = 3
    case MESSAGE_ACK_NEEDED         = 4
    case MESSAGE_SENDER_ACK_NEEDED  = 5
    case ACK                        = 6
    case GET_REGISTERED_PEERS       = 7
    case PEER_REMOVED               = -3
    case REGISTER_QUEUE             = -2
    case NOT_REGISTERED             = -1
    case ERROR_MESSAGE              = -99
}
