import Foundation

/// A mechanism to track the current app version state.
///
/// Useful for checking if it's a clean install or an app update.
/// Example of a possible implementation (at a call site):
///
///     switch version.state {
///     case .new:
///         // clean install
///     case .equal:
///         // nothing changed
///     case .update(from: let oldVersion, to: let newVersion):
///         // update is here
///     case .rollback(from: let previousVersion, to: let currentVersion):
///         // there must be a good reason
///     }
///
public struct Version: CustomStringConvertible {

    public let current: Semantic
    public let history: History
    public let state: State

    public init(
        current: Semantic,
        history: History = .load()
    ) {
        self.current = current
        self.history = history

        state = State(old: history.all.last, new: current)

        if state != .equal {
            history.save(current)
        }
    }

    public init(_ currentVersion: String) {
        self.init(current: .init(currentVersion))
    }

    public var description: String {
        """
        version: \(current)
        history: \(history)
        state: \(state)
        """
    }

    public struct Semantic: Equatable, Comparable, Codable, CustomStringConvertible {
        public let major: Int
        public let minor: Int
        public let patch: Int

        public var description: String {
            "\(major).\(minor).\(patch)"
        }

        public init(_ major: Int, _ minor: Int, _ patch: Int = 0) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        public init(_ value: String) {
            let components = value.components(separatedBy: ".")
            let major = components.indices ~= 0 ? Int(components[0]) ?? 0 : 0
            let minor = components.indices ~= 1 ? Int(components[1]) ?? 0 : 0
            let patch = components.indices ~= 2 ? Int(components[2]) ?? 0 : 0
            self = .init(major, minor, patch)
        }

        public static func < (lhs: Semantic, rhs: Semantic) -> Bool {
            guard lhs != rhs else { return false }
            let lhsComparators = [lhs.major, lhs.minor, lhs.patch]
            let rhsComparators = [rhs.major, rhs.minor, rhs.patch]
            return lhsComparators.lexicographicallyPrecedes(rhsComparators)
        }
    }

    public struct History: CustomStringConvertible {
        public let all: [Semantic]

        public init(_ all: [Semantic]) {
            self.all = all
        }

        public var description: String {
            all.description
        }

        public static func load(
            key: String = Self.key,
            defaults: UserDefaults = Self.defaults
        ) -> Self {
            self.defaults = defaults
            self.key = key

            guard
                let savedData = defaults.object(forKey: key) as? Data,
                let savedHistory = try? JSONDecoder().decode([Semantic].self, from: savedData)
            else {
                return .init([])
            }

            return .init(savedHistory)
        }

        public func save(_ current: Semantic) {
            let newHistory = all + [current]
            if let newData = try? JSONEncoder().encode(newHistory) {
                Self.defaults.set(newData, forKey: Self.key)
                Self.defaults.synchronize()
            }
        }

        public private(set) static var key: String = "Version.History"
        public private(set) static var defaults: UserDefaults = .standard
    }

    public enum State: Equatable {
        case new
        case equal
        case update(from: Semantic, to: Semantic)
        case rollback(from: Semantic, to: Semantic)

        public init(old: Semantic?, new: Semantic) {
            guard let old = old else {
                self = .new; return
            }
            if old == new {
                self = .equal
            } else if old < new {
                self = .update(from: old, to: new)
            } else {
                self = .rollback(from: old, to: new)
            }
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (new, new):
                return true
            case (equal, equal):
                return true
            case (update(from: let lf, to: let lt), update(from: let rf, to: let rt)):
                return lf == rf && lt == rt
            case (rollback(from: let lf, to: let lt), rollback(from: let rf, to: let rt)):
                return lf == rf && lt == rt
            default:
                return false
            }
        }
    }

}
