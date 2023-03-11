# FanapPodAsyncSDK
<img src="https://gitlab.com/hamed8080/fanappodasyncsdk/-/raw/gl-pages/.docs/favicon.svg"  width="64" height="64">
<br />
<br />

Fanap's POD Async iOS SDK
## Features

- [x] Simplify Socket connection to Async server

<br />

## Installation

#### Swift Package Manager(SPM) 

Add in `Package.swift` or directly in `Xcode Project dependencies` section:

```swift
.package(url: "https://pubgi.fanapsoft.ir/chat/ios/fanappodasyncsdk.git", .upToNextMinor(from: "1.2.0")),
```

#### [CocoaPods](https://cocoapods.org) 

Add in `Podfile`:

```ruby
pod 'FanapPodAsyncSDK'
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
<br/>

## Send data 
```swift
async.sendData(type: .message, message: message)
```
<br/>
<br/>

## [Documentation](https://hamed8080.gitlab.io/fanappodasyncsdk/documentation/fanappodasyncsdk/)
For more information about how to use Async SDK visit [Documentation](https://hamed8080.gitlab.io/fanappodasyncsdk/documentation/fanappodasyncsdk/) 
<br/>
<br/>

## [Developer Application](https://github.com/hamed8080/ChatApplication)
For more example and usage you can use [developer implementation app](https://github.com/hamed8080/ChatImplementation)

## Contributing to FanapPodAsyncSDK

Please see the [contributing guide](/CONTRIBUTING.md) for more information.
