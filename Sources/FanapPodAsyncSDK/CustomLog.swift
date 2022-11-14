//
//  CustomLog.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

protocol LoggerProtocol {
    init(logger: LoggerProtocol)
    func log()
}

protocol ConsoleLogger: LoggerProtocol {

}

protocol FileLogger: LoggerProtocol {

}

class NewLogger: LoggerProtocol {

    required init(logger: LoggerProtocol) {

    }

    func log() {

    }
}

class Logger{
    private var isDebuggingLogEnabled:Bool
    
    init(isDebuggingLogEnabled:Bool){
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
    }
    
    func log(title:String? = nil ,jsonString:String? = nil){
        if  isDebuggingLogEnabled{
            if let title = title{
                print(title)
            }
            if let jsonString = jsonString {
                print("\(jsonString.preetyJsonString())")
            }
            print("\n")
        }
    }
}

