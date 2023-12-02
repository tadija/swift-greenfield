// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Modules",

    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],

    products: [
        .library(name: "Demo", targets: ["Demo"]),
        .library(name: "MenuBar", targets: ["MenuBar"]),
    ],

    dependencies: [
        .package(path: "../Shared"),
    ],

    targets: [
        .target(name: "Demo", dependencies: ["Shared"]),
        .testTarget(name: "DemoTests", dependencies: ["Demo"]),

        .target(name: "MenuBar"),
        .testTarget(name: "MenuBarTests", dependencies: ["MenuBar"])
    ]
)
