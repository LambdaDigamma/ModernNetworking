// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "ModernNetworking",
    platforms: [.iOS(.v14), .tvOS(.v13), .macOS(.v11), .watchOS(.v7)],
    products: [
        .library(
            name: "ModernNetworking",
            targets: ["ModernNetworking"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ModernNetworking",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "ModernNetworkingTests",
            dependencies: ["ModernNetworking"]
        ),
    ]
)
