// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ModernNetworking",
    platforms: [.iOS(.v11), .tvOS(.v13), .macOS(.v11), .watchOS(.v7)],
    products: [
        .library(
            name: "ModernNetworking",
            targets: ["ModernNetworking"]
        ),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "ModernNetworking",
            dependencies: []
        ),
        .testTarget(
            name: "ModernNetworkingTests",
            dependencies: ["ModernNetworking"]
        ),
    ]
)
