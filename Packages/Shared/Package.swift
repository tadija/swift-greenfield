// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Shared",

    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],

    products: [
        .library(name: "Shared", targets: ["Shared"]),
    ],

    dependencies: [
        .package(url: "https://github.com/tadija/swift-minions.git", branch: "main"),
    ],

    targets: [
        .target(
            name: "Shared",
            dependencies: [.product(name: "Minions", package: "swift-minions")],
            resources: [
                .copy("Resources/Assets.xcassets"),
                .process("Resources/Fonts"),
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-application-extension"])
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-application_extension"])
            ]
        ),

        .testTarget(name: "SharedTests", dependencies: ["Shared"]),
    ]
)
