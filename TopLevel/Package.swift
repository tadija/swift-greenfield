// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TopLevel",

    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],

    products: [
        .library(name: "TopLevel", targets: ["TopLevel"]),
    ],

    dependencies: [
        .package(path: "../Packages/Modules"),
    ],

    targets: [
        .target(name: "TopLevel", dependencies: [
            .product(name: "Demo", package: "Modules"),
            .product(name: "MenuBar", package: "Modules"),
        ]),
        .testTarget(name: "TopLevelTests", dependencies: ["TopLevel"]),
    ]
)
