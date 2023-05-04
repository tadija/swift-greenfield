// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Utils",

    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .macOS(.v12)
    ],

    products: [
        .library(name: "Utils", targets: ["Utils"]),
    ],

    dependencies: [],

    targets: [
        .target(name: "Utils", dependencies: []),
        .testTarget(name: "UtilsTests", dependencies: ["Utils"]),
    ]
)
