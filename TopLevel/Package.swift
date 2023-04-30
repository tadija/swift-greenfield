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
        .package(path: "../Packages/Utils"),
    ],

    targets: [
        .target(
            name: "TopLevel",
            dependencies: [
                .product(name: "Utils", package: "Utils")
            ],
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
        .testTarget(
            name: "TopLevelTests",
            dependencies: ["TopLevel"]
        ),
    ]
)
