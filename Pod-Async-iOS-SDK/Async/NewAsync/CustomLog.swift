//
//  CustomLog.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

class Logger{
    private var isDebuggingLogEnabled:Bool
    
    init(isDebuggingLogEnabled:Bool){
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
    }
    
    func log(_ message:String){        
        if  isDebuggingLogEnabled{
            print("\(message)")
        }
    }
}

