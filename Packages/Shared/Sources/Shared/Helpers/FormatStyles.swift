import Foundation

// MARK: - Custom Timestamp

public extension FormatStyle where Self == CustomTimestampFormatStyle {
    static var customTimestamp: Self {
        .init()
    }
}

public struct CustomTimestampFormatStyle: FormatStyle {

    public typealias FormatInput = Date
    public typealias FormatOutput = String

    public func format(_ value: Date) -> String {
        Self.formatter.format(value)
    }

    private static let formatter = Date.VerbatimFormatStyle(
        format: customFormat,
        timeZone: .current,
        calendar: .current
    )

    private static let customFormat: Date.FormatString = """
    \(year: .defaultDigits)\
    -\(month: .twoDigits)\
    -\(day: .twoDigits)\
    _\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))\
    -\(minute: .twoDigits)\
    -\(second: .twoDigits)\
    .\(secondFraction: .fractional(3))
    """
}
