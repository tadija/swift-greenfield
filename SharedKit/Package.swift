// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SharedKit",

    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],

    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        ),
    ],

    dependencies: [
        .package(url: "https://github.com/tadija/AEKit.git", from: "0.1.0"),
    ],

    targets: [
        .target(
            name: "Common",
            dependencies: [
                "AEKit",
            ],
            resources: [
                .copy("Resources/Assets.xcassets"),
            ]
        ),
        .testTarget(
            name: "CommonTests",
            dependencies: ["Common"]
        ),
    ]
)
