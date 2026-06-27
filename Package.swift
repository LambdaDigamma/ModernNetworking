// swift-tools-version:6.2

import PackageDescription

let settings: [SwiftSetting] = [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances")
]

let package = Package(
    name: "ModernNetworking",
    platforms: [.iOS(.v14), .tvOS(.v13), .macOS(.v12), .watchOS(.v7)],
    products: [
        .library(
            name: "ModernNetworking",
            targets: ["ModernNetworking"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ModernNetworking",
            dependencies: [
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "ModernNetworkingTests",
            dependencies: ["ModernNetworking"],
            swiftSettings: settings
        ),
    ]
)
