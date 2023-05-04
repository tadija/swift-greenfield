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
        .package(path: "../Packages/Demo"),
    ],

    targets: [
        .target(
            name: "TopLevel",
            dependencies: [
                "Demo"
            ]
        ),

        .testTarget(name: "TopLevelTests", dependencies: ["TopLevel"]),
    ]
)
