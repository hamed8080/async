// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Async",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "Async", targets: ["Async"]),
    ],
    dependencies: [
        .package(url: "https://pubgi.sandpod.ir/chat/ios/logger", from: "1.2.1"),
        .package(url: "https://pubgi.sandpod.ir/chat/ios/mocks", from: "1.2.1"),
        .package(url: "https://pubgi.sandpod.ir/chat/ios/additive", from: "1.2.1"),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.1.1")),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        .target(name: "Async", dependencies: [
            "Starscream",
            .product(name: "Additive", package: "additive"),
            .product(name: "Logger", package: "logger"),
        ]),
        .testTarget(name: "AsyncTests",
                    dependencies: [
                        .product(name: "Additive", package: "additive"),
                        .product(name: "Mocks", package: "mocks"),
                        .product(name: "Logger", package: "logger"),
                    ],
                    path: "Tests"),
    ]
)
