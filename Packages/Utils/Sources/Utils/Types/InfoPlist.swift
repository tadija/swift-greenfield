import Foundation

/// Provides basic access to bundle's info dictionary (**Info.plist**).
///
/// Convenience API for decoding custom dictionaries from **Info.plist**.
/// Example of a possible implementation:
///
///     let info = InfoPlist()
///
///     let config: Config = try! info.decode("Config")
///
///     var baseURL: URL {
///         URL(string: config.baseURL)!
///     }
///
///     struct Config: Codable {
///         let baseURL: String
///     }
///
public struct InfoPlist {

    public let bundle: Bundle

    public init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    /// Get any custom object from "Info.plist"
    public subscript(_ key: String) -> Any? {
        infoDictionary[key]
    }

    public var infoDictionary: [String: Any] {
        bundle.infoDictionary ?? [:]
    }

    public func object(forKey key: String) -> Any? {
        bundle.object(forInfoDictionaryKey: key)
    }

    public func array(forKey key: String) -> [Any] {
        object(forKey: key) as? [Any] ?? []
    }

    public func dictionary(forKey key: String) -> [String: Any] {
        object(forKey: key) as? [String: Any] ?? [:]
    }

    public func bool(forKey key: String) -> Bool {
        object(forKey: key) as? Bool ?? false
    }

    public func data(forKey key: String) -> Data {
        object(forKey: key) as? Data ?? .init()
    }

    public func date(forKey key: String) -> Date {
        object(forKey: key) as? Date ?? .init()
    }

    public func number(forKey key: String) -> NSNumber {
        object(forKey: key) as? NSNumber ?? .init()
    }

    public func string(forKey key: String) -> String {
        object(forKey: key) as? String ?? .init()
    }

    public func decode<T: Codable>(_ key: String) throws -> T {
        try dictionary(forKey: key).jsonDecode()
    }

}
