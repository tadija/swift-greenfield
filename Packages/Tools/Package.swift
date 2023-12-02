// swift-tools-version: 5.9

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
            url: "https://github.com/realm/SwiftLint/releases/download/0.54.0/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "963121d6babf2bf5fd66a21ac9297e86d855cbc9d28322790646b88dceca00f1"
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
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.52.10/swiftformat.artifactbundle.zip",
            checksum: "6c11b2d50ee6f914ee87e891ad4e4a32e1f82993a8ccecaebd3285ac767b86ce"
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
