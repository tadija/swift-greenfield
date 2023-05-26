// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Features",

    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],

    products: [
        .library(name: "Features", targets: ["Features"]),
    ],

    dependencies: [
        .package(path: "../Shared"),
    ],

    targets: [
        .target(name: "Features", dependencies: ["Shared"]),
        .testTarget(name: "FeaturesTests", dependencies: ["Features"]),
    ]
)
