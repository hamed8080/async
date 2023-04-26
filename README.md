# Async
A Swift Async SDK which handle all backend communication with Async Server.

<img src="https://github.com/hamed8080/async/raw/main/images/icon.png" width="164" height="164">

## Features
- [x] Simplify Socket connection to Async server

## Installation

#### Swift Package Manager(SPM) 

Add in `Package.swift` or directly in `Xcode Project dependencies` section:

```swift
.package(url: "https://pubgi.fanapsoft.ir/chat/ios/async.git", .upToNextMinor(from: "1.3.1")),
```

#### [CocoaPods](https://cocoapods.org) 

Because it has conflict with other Pods' names in cocoapods you have to use direct git repo.
Add in `Podfile`:

```ruby
 pod 'Starscream', :git => 'https://github.com/daltoniam/Starscream.git', :tag => '3.0.5'
 pod 'Additive', :git => 'http://pubgi.fanapsoft.ir/chat/ios/additive.git', :tag => '1.0.1'
 pod 'Logger', :git => 'http://pubgi.fanapsoft.ir/chat/ios/logger.git', :tag => '1.0.2'
 pod "Async", :git => 'http://pubgi.fanapsoft.ir/chat/ios/async.git', :tag => '1.3.1'
```

## How to use? 

```swift
let asyncConfig = AsyncConfigBuilder()
            .socketAddress("socketAddresss")
            .reconnectCount(Int.max)
            .reconnectOnClose(true)
            .appId("PodChat")
            .serverName("serverName")
            .isDebuggingLogEnabled(false)
            .build()
let async = Async(config: asyncConfig, delegate: self)
async.createSocket()
```

## Connection State
Notice: Use the connection only it's in <b>ASYNC_READY</b> state  
```swift
public func asyncStateChanged(asyncState: AsyncSocketState, error: AsyncError?) {
    Chat.sharedInstance.delegate?.chatState(state: asyncState.chatState, currentUser: nil, error: error?.chatError)
    if asyncState == .ASYNC_READY{
        // Write your code here.
    }
}
```
<br/>

## Send data 
```swift
async.sendData(type: .message, message: message)
```
<br/>

## [Documentation](https://hamed8080.github.io/async/async/documentation/async/)
For more information about how to use Async SDK visit [Documentation](https://hamed8080.github.io/async/async/documentation/async/) 
<br/>
<br/>

## [Developer Application](https://github.com/hamed8080/ChatApplication)
For more example and usage you can use [developer implementation app](https://github.com/hamed8080/ChatImplementation)

## Contributing to Async

Please see the [contributing guide](/CONTRIBUTING.md) for more information.
