import Foundation
import Minions

// MARK: - Environment

/// Type which encapsulates current environment info.
public struct Env: CustomStringConvertible {

    /// Build configuration and custom config
    @Dependency(\.buildConfig) public private(set) var buildConfig

    /// A collection of information about current device
    @Dependency(\.device) public private(set) var device

    /// A mechanism to track current app version state
    @Dependency(\.version) public private(set) var version

    /// String describing custom environment
    public var description: String {
        """
        + build config \n\(buildConfig)\n
        + custom config \n\(config)\n
        + device info \n\(device)\n
        + app version \n\(version)\n
        """
    }

}

// MARK: - Custom Environments

extension Env: Identifiable {

    /// Custom environments
    public enum ID: String, Codable {
        case dev = "Dev"
        case live = "Live"
    }

    /// A flag which determines if current environment is "Dev"
    public var isDev: Bool {
        id == .dev
    }

    /// A flag which determines if current environment is "Live"
    public var isLive: Bool {
        id == .live
    }

    /// Resolved custom environment `ID`.
    public var id: ID {
        config.envID
    }

    /// Current build configuration - $(CONFIGURATION)
    public var buildConfiguration: String {
        config.buildConfiguration
    }

    /// A flag which determines if app is running in "Debug" mode
    public var isDebug: Bool {
        buildConfiguration.contains("Debug")
    }

    /// A flag which determines if app is running in "Release" mode
    public var isRelease: Bool {
        buildConfiguration.contains("Release")
    }

}

// MARK: - Custom config

/// Extends `Env` with custom config.
extension Env {

    /// Custom environment config
    public struct Config: Codable, CustomStringConvertible {

        public let buildConfiguration: String
        public let envID: Env.ID

        /// String describing custom environment config
        public var description: String {
            """
            build configuration: \(buildConfiguration)
            environment id: \(envID.rawValue)
            """
        }
    }

    /// Decoded custom environment config
    public var config: Config {
        do {
            return try buildConfig.customConfig.jsonDecode()
        } catch {
            if ProcessInfo.isXcodePreview {
                /// - Note: Xcode does not propagate custom config / build configurations to Swift packages.
                return Config(
                    buildConfiguration: "Debug",
                    envID: .dev
                )
            } else {
                fatalError("❌ failed decoding config with error: \(error)")
            }
        }
    }

}
