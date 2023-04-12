// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "TopLevel",

    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],

    products: [
        .library(name: "TopLevel", targets: ["TopLevel"]),
    ],

    dependencies: [
        .package(url: "https://github.com/tadija/AEKit.git", from: "0.1.0"),
    ],

    targets: [
        .target(
            name: "TopLevel",
            dependencies: [
                "AEKit",
            ],
            resources: [
                .copy("Resources/Assets.xcassets"),
            ]
        ),
        .testTarget(
            name: "TopLevelTests",
            dependencies: ["TopLevel"]
        ),
    ]
)
