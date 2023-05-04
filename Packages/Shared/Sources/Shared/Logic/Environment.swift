import Utils

// MARK: - Environment

/// Extends `Env` with custom environments.
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
    public struct Config: Codable {
        public let buildConfiguration: String
        public let envID: Env.ID
    }

    /// Decoded custom environment config
    public var config: Config {
        do {
            return try configDictionary.jsonDecode()
        } catch {
            if isXcodePreview {
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

// MARK: - Custom helpers

extension Env {

    /// A collection of information about the current device
    public var device: Device {
        .init()
    }

    /// A mechanism to track the current app version state
    public var version: Version {
        .init(bundleVersion)
    }

    /// String describing custom environment & configuration
    public var customDescription: String {
        """
        + device \n\(device)\n
        + product \n\(self)\n
        + config \n\(config)\n
        + version \n\(version)\n
        """
    }

}

extension Env.Config: CustomStringConvertible {

    /// String describing custom environment config
    public var description: String {
        """
        build configuration: \(buildConfiguration)
        environment id: \(envID.rawValue)
        """
    }

}
