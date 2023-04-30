import Foundation

/// A collection of information about the current device.
///
/// Provides a strongly typed access to the various device information such as:
///
///     public enum Kind: String {
///         case mac, iPhone, iPad, iPod, watch, tv, unknown
///     }
///
///     public enum Platform: String {
///         case macOS, macCatalyst, iOS, watchOS, tvOS, linux, unknown
///     }
///
public struct Device: CustomStringConvertible {

    public enum Kind: String {
        case mac, iPhone, iPad, iPod, watch, tv, unknown
    }

    public enum Platform: String {
        case macOS, macCatalyst, iOS, watchOS, tvOS, linux, unknown
    }

    public let model: String = modelIdentifier()

    public let kind: Kind = kind()

    public let platform: Platform = platform()

    public let osVersion: String = osVersion()

    public let isSimulator: Bool = isSimulator()

    public init() {}

    public var description: String {
        """
        model: \(model)
        kind: \(kind)
        platform: \(platform)
        os version: \(osVersion)
        simulator: \(isSimulator)
        """
    }

    private static func modelIdentifier() -> String {
        if let simulatorID = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorID
        } else {
            var sysinfo = utsname()
            uname(&sysinfo)
            return String(
                bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)),
                encoding: .ascii
            )?.trimmingCharacters(in: .controlCharacters) ?? ""
        }
    }

    private static func kind() -> Kind {
        switch platform() {
        case .macOS, .macCatalyst:
            return .mac
        case .watchOS:
            return .watch
        case .tvOS:
            return .tv
        case .iOS:
            switch modelIdentifier() {
            case let id where id.contains(Kind.iPhone.rawValue):
                return .iPhone
            case let id where id.contains(Kind.iPad.rawValue):
                return .iPad
            case let id where id.contains(Kind.iPod.rawValue):
                return .iPod
            default:
                return .unknown
            }
        case .linux, .unknown:
            return .unknown
        }
    }

    private static func platform() -> Platform {
        #if os(macOS)
        return .macOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(tvOS)
        return .tvOS
        #elseif os(iOS)
        #if targetEnvironment(macCatalyst)
        return .macCatalyst
        #else
        return .iOS
        #endif
        #elseif os(Linux)
        return .linux
        #else
        return .unknown
        #endif
    }

    private static func osVersion() -> String {
        let os = ProcessInfo().operatingSystemVersion
        let version = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        return version
    }

    private static func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

}
