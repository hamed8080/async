// swift-tools-version:5.6

import PackageDescription

let useLocalDependency = true

let local: [Package.Dependency] = [
    .package(path: "../Logger"),
    .package(path: "../Mocks"),
    .package(path: "../Additive"),
    .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.1.1")),
    .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
]

let remote: [Package.Dependency] = [
    .package(url: "https://pubgi.sandpod.ir/chat/ios/logger", from: "1.2.2"),
    .package(url: "https://pubgi.sandpod.ir/chat/ios/mocks", from: "1.2.3"),
    .package(url: "https://pubgi.sandpod.ir/chat/ios/additive", from: "1.2.2"),
    .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.1.1")),
    .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
]

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
    dependencies: useLocalDependency ? local : remote,
    targets: [
        .target(name: "Async",
                dependencies: [
                    "Starscream",
                    .product(name: "Additive", package: useLocalDependency ? "Additive" : "additive"),
                    .product(name: "Logger", package: useLocalDependency ? "Logger" : "logger"),
                ]),
        .testTarget(name: "AsyncTests",
                    dependencies: [
                        .product(name: "Additive", package: useLocalDependency ? "Additive" : "additive"),
                        .product(name: "Logger", package: useLocalDependency ? "Logger" : "logger"),
                        .product(name: "Mocks", package: useLocalDependency ? "Mocks" : "mocks"),
                    ],
                    path: "Tests"),
    ]
)
