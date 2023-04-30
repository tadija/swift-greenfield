import Foundation

/// Helper for accesssing "App Groups" shared data (`UserDefaults` or file system).
///
/// It can be created with an explicit `groupID` or with a *standard one*.
/// Example of a possible implementation:
///
///     let info = InfoPlist()
///     let config: Config = try! info.decode("Config")
///
///     let group = AppGroup.standard(
///         bundleID: info.bundleID,
///         teamID: config.teamID
///     )
///
public struct AppGroup: CustomStringConvertible {

    public let groupID: String

    public init(groupID: String) {
        self.groupID = groupID
    }

    public var description: String {
        """
        group id: \(groupID)
        directory: \(directory?.absoluteString ?? "n/a")
        """
    }

    public var defaults: UserDefaults {
        UserDefaults(suiteName: groupID) ?? .standard
    }

    public var directory: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: groupID)
    }

    public static func standard(
        bundleID: String,
        teamID: String
    ) -> Self {
        let prefix = "group"
        let groupID: String
        #if os(macOS)
        groupID = "\(teamID).\(prefix).\(bundleID)"
        #else
        groupID = "\(prefix).\(bundleID)"
        #endif
        return Self(groupID: groupID)
    }

}
