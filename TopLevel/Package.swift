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
        .package(path: "../Packages/Features"),
    ],

    targets: [
        .target(
            name: "TopLevel",
            dependencies: [
                "Features"
            ]
        ),

        .testTarget(name: "TopLevelTests", dependencies: ["TopLevel"]),
    ]
)
