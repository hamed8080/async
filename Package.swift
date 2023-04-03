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
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.1.1")),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
        .package(url: "https://github.com/hamed8080/logger.git", branch: "main"),
        .package(url: "https://github.com/hamed8080/additive.git", branch: "main"),
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
