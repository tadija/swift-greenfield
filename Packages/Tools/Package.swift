// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Tools",

    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .macOS(.v12),
    ],

    products: [
        .plugin(name: "SwiftLint", targets: ["SwiftLint"]),
        .plugin(name: "SwiftGen", targets: ["SwiftGen"]),
        .plugin(name: "SwiftFormat", targets: ["SwiftFormat"]),
    ],

    targets: [
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.52.3/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "05cbe202aae733ce395de68557614b0dfea394093d5ee53f57436e4d71bbe12f"
        ),
        .plugin(
            name: "SwiftLint",
            capability: .buildTool(),
            dependencies: ["SwiftLintBinary"]
        ),

        .binaryTarget(
            name: "SwiftGenBinary",
            url: "https://github.com/SwiftGen/SwiftGen/releases/download/6.6.2/swiftgen-6.6.2.artifactbundle.zip",
            checksum: "7586363e24edcf18c2da3ef90f379e9559c1453f48ef5e8fbc0b818fbbc3a045"
        ),
        .plugin(
            name: "SwiftGen",
            capability: .command(
                intent: .sourceCodeFormatting(),
                permissions: [
                    .writeToPackageDirectory(reason: "This command generates source code")
                ]
            ),
            dependencies: ["SwiftGenBinary"]
        ),

        .binaryTarget(
            name: "SwiftFormatBinary",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.51.12/swiftformat.artifactbundle.zip",
            checksum: "0310600634dda94aeaae6cf305daa6cf2612712dd5760b0791b182db98d0521e"
        ),
        .plugin(
            name: "SwiftFormat",
            capability: .command(
                intent: .sourceCodeFormatting(),
                permissions: [
                    .writeToPackageDirectory(reason: "This command reformats source files"),
                ]
            ),
            dependencies: ["SwiftFormatBinary"]
        ),
    ]
)
