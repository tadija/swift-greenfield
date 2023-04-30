import Foundation

/// Provides environment information.
///
/// To enable, define "Config" dictionary within "Info.plist" file.
/// Add any custom items to this dictionary, for example:
/// key: "buildConfiguration" | type: String | value: $(CONFIGURATION)
///
/// - Attention: Make sure to keep this "Config" dictionary in sync
/// across all targets that will use it (for each target's "Info.plist").
///
/// Example of a posssible usage:
///
///     extension Env {
///         var isDev: Bool {
///             buildConfiguration.contains("Dev")
///         }
///
///         var isLive: Bool {
///             buildConfiguration.contains("Live")
///         }
///
///         var buildConfiguration: String {
///             configDictionary["buildConfiguration"] as? String ?? "n/a"
///         }
///     }
///
public struct Env {

    public let info: InfoPlist

    /// Environment information provider
    ///
    /// - Parameters:
    ///   - info: "Info.plist" (defaults to `.init(bundle: Bundle = .main)`)
    ///   - configDictionaryKey: key for a custom config in "Info.plist" (defaults to "Config")
    ///
    public init(
        info: InfoPlist = .init(),
        configDictionaryKey: String = "Config"
    ) {
        self.info = info
        self.configDictionaryKey = configDictionaryKey
    }

    /// Access to custom "Config" dictionary from "Info.plist"
    public var configDictionary: [String: Any] {
        info[configDictionaryKey] as? [String: Any] ?? [:]
    }

    private let configDictionaryKey: String

}

extension Env: CustomStringConvertible {

    /// Multi-line string with basic environment information
    public var description: String {
        """
        product name: \(productName)
        bundle id: \(bundleID)
        bundle version: \(bundleVersion)
        bundle build: \(bundleBuild)
        """
    }

    /// Product name
    public var productName: String {
        info.string(forKey: kCFBundleNameKey as String)
    }

    /// Bundle identifier
    public var bundleID: String {
        info.string(forKey: kCFBundleIdentifierKey as String)
    }

    /// Bundle version
    public var bundleVersion: String {
        info.string(forKey: "CFBundleShortVersionString")
    }

    /// Bundle build
    public var bundleBuild: String {
        info.string(forKey: kCFBundleVersionKey as String)
    }

    /// Bundle version and build formatted as "Version (Build)"
    public var versionBuild: String {
        "\(bundleVersion) (\(bundleBuild))"
    }

    /// A flag which determines if code is run in the context of Test Flight build
    public var isTestFlight: Bool {
        info.bundle.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    /// A flag which determines if code is run in the context of Xcode's "Live Preview"
    public var isXcodePreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

}
