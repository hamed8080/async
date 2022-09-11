//
//  NSObjectEX.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/31/21.
//

import Foundation
extension NSObject{

    /// Address of the object in memory in string.
    public var addressOfObjectInMemory:String?{
         let address = Unmanaged.passUnretained(self).toOpaque()
        return "\(address)"
    }
}
