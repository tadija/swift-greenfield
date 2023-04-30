import Foundation

/// Convenient property wrappers for `UserDefaults`.
///
/// Supports property list values, `RawRepresentable` or `Codable` types.
/// Example of a possible implementation:
///
///     enum Key: String {
///         case sound
///         case appearance
///         case location
///     }
///
///     @DefaultsValue(key: Key.sound)
///     var isSoundEnabled: Bool = true
///
///     @DefaultsRaw(key: Key.appearance)
///     var appearance: Appearance = .system
///
///     @DefaultsCodable(key: Key.location)
///     var location: Location = .init()
///
///     struct Location: Codable {
///         var lat: Double = 0
///         var long: Double = 0
///     }
///
public struct Defaults {

    public static var customStorage: UserDefaults?

    public static var storage: UserDefaults {
        customStorage ?? .standard
    }

    public let storage: UserDefaults

    public init(storage: UserDefaults = Self.storage) {
        self.storage = storage
    }

    subscript<T>(key: String, storage: UserDefaults = Self.storage) -> T? {
        get {
            storage.value(forKey: key) as? T
        }
        set {
            storage.setOptionalValue(newValue, forKey: key)
        }
    }

    func removeValue(for key: String, storage: UserDefaults = Self.storage) {
        storage.removeObject(forKey: key)
    }

    func persist(storage: UserDefaults = Self.storage) {
        storage.synchronize()
    }

}

public extension Defaults {
    subscript<T: RawRepresentable>(key: String, storage: UserDefaults = Self.storage) -> T? {
        get {
            storage.rawValue(forKey: key)
        }
        set {
            storage.setRawValue(newValue, forKey: key)
        }
    }

    subscript<T: Codable>(key: String, storage: UserDefaults = Self.storage) -> T? {
        get {
            storage.codableValue(forKey: key)
        }
        set {
            storage.setCodableValue(newValue, forKey: key)
        }
    }
}

// MARK: - Property Wrappers

@propertyWrapper
public struct DefaultsValue<T> {
    public let key: String
    public let value: T
    public let storage: UserDefaults

    public var wrappedValue: T {
        get {
            storage.object(forKey: key) as? T ?? value
        }
        set {
            storage.setOptionalValue(newValue, forKey: key)
        }
    }

    public init(
        wrappedValue value: T,
        key: String,
        storage: UserDefaults = Defaults.storage
    ) {
        self.value = value
        self.key = key
        self.storage = storage
    }
}

@propertyWrapper
public struct DefaultsRaw<T: RawRepresentable> {
    public let key: String
    public let value: T
    public let storage: UserDefaults

    public var wrappedValue: T {
        get {
            storage.rawValue(forKey: key) ?? value
        }
        set {
            storage.setRawValue(newValue, forKey: key)
        }
    }

    public init(
        wrappedValue value: T,
        key: String,
        storage: UserDefaults = Defaults.storage
    ) {
        self.value = value
        self.key = key
        self.storage = storage
    }
}

@propertyWrapper
public struct DefaultsCodable<T: Codable> {
    public let key: String
    public let value: T
    public let storage: UserDefaults

    public var wrappedValue: T {
        get {
            storage.codableValue(forKey: key) ?? value
        }
        set {
            storage.setCodableValue(newValue, forKey: key)
        }
    }

    public init(
        wrappedValue value: T,
        key: String,
        storage: UserDefaults = Defaults.storage
    ) {
        self.value = value
        self.key = key
        self.storage = storage
    }
}

public extension DefaultsValue where T: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = Defaults.storage) {
        self.init(wrappedValue: nil, key: key, storage: storage)
    }
}

public extension DefaultsRaw where T: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = Defaults.storage) {
        self.init(wrappedValue: nil, key: key, storage: storage)
    }
}

public extension DefaultsCodable where T: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = Defaults.storage) {
        self.init(wrappedValue: nil, key: key, storage: storage)
    }
}

// MARK: - Helpers

private extension UserDefaults {
    func setOptionalValue<T>(_ newValue: T, forKey key: String) {
        if let optional = newValue as? AnyOptional, optional.isNil {
            removeObject(forKey: key)
        } else {
            set(newValue, forKey: key)
        }
    }

    func rawValue<T: RawRepresentable>(forKey key: String) -> T? {
        guard let rawValue = value(forKey: key) as? T.RawValue else {
            return nil
        }
        return T(rawValue: rawValue)
    }

    func setRawValue<T: RawRepresentable>(_ newValue: T?, forKey key: String) {
        if let optional = newValue as? AnyOptional, optional.isNil {
            removeObject(forKey: key)
        } else {
            set(newValue?.rawValue, forKey: key)
        }
    }

    func codableValue<T: Codable>(forKey key: String) -> T? {
        guard let data = object(forKey: key) as? Data else {
            return nil
        }
        if let decoded = try? JSONDecoder().decode(T.self, from: data) {
            return decoded
        } else {
            assertionFailure("decoding failed for key: \(key)")
            return nil
        }
    }

    func setCodableValue<T: Codable>(_ newValue: T?, forKey key: String) {
        if let optional = newValue as? AnyOptional, optional.isNil {
            removeObject(forKey: key)
        } else {
            if let encoded = try? JSONEncoder().encode(newValue) {
                set(encoded, forKey: key)
            } else {
                assertionFailure("encoding failed for key: \(key)")
            }
        }
    }
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}
