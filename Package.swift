// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Async",
    platforms: [
        .iOS(.v10),
        .macOS(.v12),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "Async", targets: ["Async"]),
    ],
    dependencies: [
//        .package(path: "../Logger"),
//        .package(path: "../Additive"),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.1.1")),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
        .package(url: "http://pubgi.fanapsoft.ir/chat/ios/logger.git", exact: "1.0.2"),
        .package(url: "http://pubgi.fanapsoft.ir/chat/ios/additive.git", exact: "1.0.1"),
    ],
    targets: [
        .target(name: "Async", dependencies: [
            "Starscream",
            .product(name: "Logger", package: "logger"),
            .product(name: "Additive", package: "additive"),
        ]),
        .testTarget(name: "AsyncTests", dependencies: ["Async"], path: "Tests"),
    ]
)
