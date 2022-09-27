# Pod-Async-iOS-SDK
<img src="https://gitlab.com/hamed8080/fanappodasyncsdk/-/raw/gl-pages/.docs/favicon.svg"  width="64" height="64">
<br />
<br />

[![Swift](https://img.shields.io/badge/Swift-5+-orange?style=flat-square)](https://img.shields.io/badge/-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_Linux_Windows-Green?style=flat-square)
[![CocoaPods Compatible](https://img.shields.io/badge/Pod-v0.10-blue)](https://img.shields.io/badge/Pod-v0.10-blue)

Fanap's POD Async iOS SDK
## Features

- [x] Simplify Socket connection to Async server

## Installation

#### [CocoaPods](https://cocoapods.org) 

Add in `Podfile`:

```ruby
pod 'FanapPodAsyncSDK'
```

## Intit 

```swift
let asyncConfig = AsyncConfig(socketAddress:                socketAddress,
                                serverName:                 serverName,
                                deviceId:                   deviceId ?? UUID().uuidString,
                                appId:                      "PodChat", // PodChat is default app Id
                                peerId:                     nil,
                                messageTtl:                 messageTtl,
                                connectionRetryInterval:    TimeInterval(connectionRetryInterval),
                                connectionCheckTimeout:     TimeInterval(connectionCheckTimeout),
                                reconnectCount:             reconnectCount,
                                reconnectOnClose:           reconnectOnClose,
                                isDebuggingLogEnabled:      isDebuggingAsyncEnable)
asyncClient = NewAsync(config: asyncConfig, delegate: self)
asyncClient?.createSocket()
```

## Connection State
Notice: Use the connection only it's in <b>ASYNC_READY</b> state  
```swift
public func asyncStateChanged(asyncState: AsyncSocketState, error: AsyncError?) {
    Chat.sharedInstance.delegate?.chatState(state: asyncState.chatState, currentUser: nil, error: error?.chatError)
    if asyncState == .ASYNC_READY{
        UserInfoRequestHandler.getUserForChatReady()
    }
}
```
<br/>
<br/>

## Send data 
```swift
asyncClient?.sendData(type: type, data: data)
```
<br/>
<br/>

## Developer Application 
For more example and usage you can use [developer implementation app](https://github.com/hamed8080/ChatImplementation)
