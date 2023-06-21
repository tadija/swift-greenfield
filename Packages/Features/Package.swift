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

    targets: Package.makeTargets()
)

extension Package {
    static func makeTargets() -> [Target] {[
        .demo, .demoTests,
        .hello, .helloTests,
        .features, .featuresTests,
    ]}
}

extension Target {
    static var features: Target {
        .target(
            name: "Features",
            dependencies: [
                "Demo",
                "Hello",
            ]
        )
    }
    static var featuresTests: Target {
        .testTarget(name: "FeaturesTests", dependencies: ["Features"])
    }
}

extension Target {
    static var demo: Target {
        .target(name: "Demo", dependencies: ["Shared"])
    }
    static var demoTests: Target {
        .testTarget(name: "DemoTests", dependencies: ["Demo"])
    }
}

extension Target {
    static var hello: Target {
        .target(name: "Hello", dependencies: ["Shared"])
    }
    static var helloTests: Target {
        .testTarget(name: "HelloTests", dependencies: ["Hello"])
    }
}
