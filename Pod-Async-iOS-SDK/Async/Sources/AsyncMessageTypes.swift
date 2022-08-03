//
//  AsyncMessageTypes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

/// Whenever an event occurs in the server or you want to send a message, a type of message will tell you what's happening right now.
public enum AsyncMessageTypes : Int , Codable{

    /// Ping every 20 seonds to keep socket alive.
    case PING                       = 0

    /// Register with server.
    case SERVER_REGISTER            = 1

    /// Registered with server.
    case DEVICE_REGISTER            = 2

    /// A message  was received.
    case MESSAGE                    = 3

    /// A message that needs acknowledgment to tell the server Hey I received the message. It's two-directional.
    case MESSAGE_ACK_NEEDED         = 4

    /// The server needs to know if you receiving this message you should tell us.
    case MESSAGE_SENDER_ACK_NEEDED  = 5

    /// An acknowledgment of a message.
    case ACK                        = 6

    /// Not implemended.
    case GET_REGISTERED_PEERS       = 7

    /// Not implemended.
    case PEER_REMOVED               = -3

    /// Not implemended.
    case REGISTER_QUEUE             = -2

    /// Not implemended.
    case NOT_REGISTERED             = -1

    /// Not implemended.
    case ERROR_MESSAGE              = -99
}
