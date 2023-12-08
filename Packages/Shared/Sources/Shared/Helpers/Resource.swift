import Foundation

public struct Resource {
    public let name: String
    public let type: String

    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }

    public var path: String {
        guard let path = BundleToken.bundle
            .path(forResource: name, ofType: type)
        else {
            fatalError("resource not found: \(name).\(type)")
        }
        return path
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }()
}
// swiftlint:enable convenience_type
