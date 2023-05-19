// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Demo",

    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],

    products: [
        .library(name: "Demo", targets: ["Demo"]),
    ],

    dependencies: [
        .package(path: "../Shared"),
    ],

    targets: [
        .target(name: "Demo", dependencies: ["Shared"]),
        .testTarget(name: "DemoTests", dependencies: ["Demo"]),
    ]
)
