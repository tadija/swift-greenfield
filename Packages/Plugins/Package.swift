// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Plugins",

    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .macOS(.v12),
    ],

    products: [
        .plugin(
            name: "SwiftLint",
            targets: ["SwiftLint"]
        ),
        .plugin(
            name: "SwiftFormat",
            targets: ["SwiftFormat"]
        ),
    ],

    targets: [
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.51.0/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "9fbfdf1c2a248469cfbe17a158c5fbf96ac1b606fbcfef4b800993e7accf43ae"
        ),
        .plugin(
            name: "SwiftLint",
            capability: .buildTool(),
            dependencies: ["SwiftLintBinary"]
        ),

        .binaryTarget(
            name: "SwiftFormatBinary",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.51.4/swiftformat.artifactbundle.zip",
            checksum: "6e86973183fe1ed1b779a12731f901e8630bf3583ae52e54856bcc8d944568f8"
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
