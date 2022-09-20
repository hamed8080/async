// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "FanapPodAsyncSDK",
    platforms: [
        .iOS(.v10),
        .macOS(.v12),
        .macCatalyst(.v13),
    ],
    products : [
        .library(name: "FanapPodAsyncSDK", targets: ["FanapPodAsyncSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.1.1")),
    ],
    targets: [
        .target(name: "FanapPodAsyncSDK", dependencies: ["Starscream"]),
        .testTarget(name: "FanapPodAsyncSDKTests", dependencies: ["FanapPodAsyncSDK"]),
    ]
)
