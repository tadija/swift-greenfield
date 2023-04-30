#if canImport(Foundation)

import Foundation

public extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()

        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }

        return loaded
    }
}

// MARK: - Codable Helpers

/// - See: https://www.swiftbysundell.com/posts/type-inference-powered-serialization-in-swift
public extension KeyedDecodingContainerProtocol {
    func decode<T: Decodable>(_ key: Key) throws -> T {
        try decode(T.self, forKey: key)
    }

    func decodeIfPresent<T: Decodable>(_ key: Key) throws -> T? {
        try decodeIfPresent(T.self, forKey: key)
    }

    func decodeDate(_ key: Key, using formatter: DateFormatter) throws -> Date? {
        let dateString = try decodeIfPresent(key) ?? ""
        return formatter.date(from: dateString)
    }

    func decodeDates(_ key: Key, using formatter: DateFormatter) throws -> [Date]? {
        let strings: [String] = try decodeIfPresent(key) ?? []
        return strings.compactMap({ formatter.date(from: $0) })
    }
}

public extension KeyedEncodingContainerProtocol {
    mutating func encode(
        _ date: Date?,
        using formatter: DateFormatter,
        forKey key: Key
    ) throws {
        var dateString: String?
        if let date = date {
            dateString = formatter.string(from: date)
        }
        try encode(dateString, forKey: key)
    }

    mutating func encode(
        _ dates: [Date]?,
        using formatter: DateFormatter,
        forKey key: Key
    ) throws {
        var dateStrings: [String]?
        if let dates = dates {
            dateStrings = dates.compactMap({ formatter.string(from: $0) })
        }
        try encode(dateStrings, forKey: key)
    }
}

// MARK: - Data Helpers

public extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0 ..< len {
            let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }

    var hexString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}

// MARK: - Date Helpers

public extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }

    var isBeforeToday: Bool {
        self < Calendar.current.startOfDay(for: Date())
    }

    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        (min(date1, date2) ... max(date1, date2)).contains(self)
    }

    var zeroSeconds: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: components)
    }

    func withTime(hour: Int, minute: Int, second: Int = 0) -> Date? {
        Calendar.current
            .date(bySettingHour: hour, minute: minute, second: second, of: self)
    }
}

// MARK: - Dictionary Helpers

public extension Dictionary {
    func jsonEncode() throws -> Data {
        try JSONSerialization.data(
            withJSONObject: self,
            options: .prettyPrinted
        )
    }

    func jsonDecode<T: Codable>() throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self)
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
    }
}

// MARK: - Double Helpers

public extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(.toNearestOrAwayFromZero) / divisor
    }

    func toString(roundedTo places: Int) -> String {
        String(format: "%.\(places)f", roundTo(places: places))
    }
}

// MARK: - Locale Helpers

public extension Locale {
    /// - See: https://stackoverflow.com/a/12236693/2165585
    var isFormat12h: Bool {
        format.contains("a")
    }

    /// - See: https://stackoverflow.com/a/49438640/2165585
    var isFormat24h: Bool {
        !format.contains("a")
    }

    private var format: String {
        DateFormatter
            .dateFormat(fromTemplate: "j", options: 0, locale: self) ?? ""
    }
}

// MARK: - String Helpers

extension String: LocalizedError {
    public var errorDescription: String? {
        self
    }
}

public extension String {
    func hexColorToRGBA() -> (r: Double, g: Double, b: Double, a: Double) {
        var hex = self

        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }

        var rgba: (r: Double, g: Double, b: Double, a: Double) = (0, 0, 0, 1)

        let scanner = Scanner(string: hex)
        var hexValue: UInt64 = 0
        if scanner.scanHexInt64(&hexValue) {
            if hex.count == 8 {
                rgba.r = Double((hexValue & 0xFF000000) >> 24) / 255.0
                rgba.g = Double((hexValue & 0x00FF0000) >> 16) / 255.0
                rgba.b = Double((hexValue & 0x0000FF00) >> 8) / 255.0
                rgba.a = Double((hexValue & 0x000000FF)) / 255.0
            } else if hex.count == 6 {
                rgba.r = Double((hexValue & 0xFF0000) >> 16) / 255.0
                rgba.g = Double((hexValue & 0x00FF00) >> 8) / 255.0
                rgba.b = Double((hexValue & 0x0000FF)) / 255.0
            }
        }

        return rgba
    }
}

public extension String {
    var isBlank: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }

    var isNotBlank: Bool {
        !isBlank
    }

    var isValidEmail: Bool {
        validate(regex: "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$")
    }

    var isNumeric: Bool {
        validate(regex: "^[0-9]+$")
    }

    var isValidPhoneNumber: Bool {
        /// - Note: starts with 0, maximum 10 digits
        validate(regex: "^(?=0)[0-9]{10}$")
    }

    var isValidYear: Bool {
        /// - Note: has 4 digits
        validate(regex: #"^\d{4}$"#)
    }

    var isStrongPassword: Bool {
        /// - Note: lowercase, uppercase, digit, 8-50 chars
        validate(regex: "((?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,50})")
    }

    private func validate(regex: String) -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
}

// MARK: - Top Level Helpers

/// Makes sure no other thread reenters the closure before the one running has not returned
/// - See: https://stackoverflow.com/a/61458763/2165585
@discardableResult
public func synchronized<T>(_ lock: AnyObject, closure: () -> T) -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return closure()
}

// MARK: - Custom Types

/// Wraps the observer token received from
/// `NotificationCenter.addObserver(forName:object:queue:using:)`
/// and unregisters it in `deinit`.
/// - See: https://oleb.net/blog/2018/01/notificationcenter-removeobserver/
public final class NotificationToken: NSObject {
    let notificationCenter: NotificationCenter
    let token: Any

    init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}

public extension NotificationCenter {
    /// Convenience wrapper for `addObserver(forName:object:queue:using:)`
    /// that returns our custom `NotificationToken`.
    func observe(
        name: NSNotification.Name?,
        object: Any? = nil,
        queue: OperationQueue? = .main,
        then completion: @escaping (Notification) -> Void
    ) -> NotificationToken {
        let token = addObserver(
            forName: name,
            object: object,
            queue: queue,
            using: completion
        )
        return NotificationToken(notificationCenter: self, token: token)
    }
}

/// Helper class for adding stored properties with extension.
/// - See: https://stackoverflow.com/a/43056053/2165585
public final class ObjectAssociation<T: AnyObject> {

    private let policy: objc_AssociationPolicy

    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.policy = policy
    }

    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: AnyObject) -> T? {
        get {
            // swiftlint:disable force_cast
            objc_getAssociatedObject(
                index,
                Unmanaged.passUnretained(self).toOpaque()
            ) as! T?
            // swiftlint:enable force_cast
        }
        set {
            objc_setAssociatedObject(
                index,
                Unmanaged.passUnretained(self).toOpaque(),
                newValue,
                policy
            )
        }
    }

}

#endif
