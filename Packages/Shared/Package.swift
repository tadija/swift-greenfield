// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Shared",

    defaultLocalization: "en",

    platforms: [
        .iOS(.v17),
        .macOS(.v14),
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
            dependencies: [
                .product(name: "Minions", package: "swift-minions")
            ],
            resources: [
                .process("Resources"),
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
