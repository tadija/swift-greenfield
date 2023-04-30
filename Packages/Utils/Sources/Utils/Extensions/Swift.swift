// MARK: - Array Helpers

public extension Array {
    subscript(safe index: Int) -> Element? {
        indices ~= index ? self[index] : nil
    }
}

/// - See: https://stackoverflow.com/a/27624444/4606679
public extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return filter {
            seen.updateValue(true, forKey: $0) == nil
        }
    }
}

/// - See: https://stackoverflow.com/a/46354989/2165585
public extension Array where Element: Hashable {
    func removingDuplicates<T: Hashable>(byKey key: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return filter { value in
            seen.insert(key(value)).inserted
        }
    }
}

/// - See: https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

/// - See: https://www.swiftbysundell.com/articles/the-power-of-key-paths-in-swift
public extension Array {
    mutating func sortAscending<T: Comparable>(by keyPath: KeyPath<Element, T?>) {
        sort(by: {
            guard let path1 = $0[keyPath: keyPath], let path2 = $1[keyPath: keyPath] else {
                return false
            }
            return path1 < path2
        })
    }

    mutating func sortDescending<T: Comparable>(by keyPath: KeyPath<Element, T?>) {
        sort(by: {
            guard let path1 = $0[keyPath: keyPath], let path2 = $1[keyPath: keyPath] else {
                return false
            }
            return path1 > path2
        })
    }
}

public extension Array {
    func sortedAscending<T: Comparable>(by keyPath: KeyPath<Element, T?>) -> [Element] {
        sorted(by: {
            guard let path1 = $0[keyPath: keyPath], let path2 = $1[keyPath: keyPath] else {
                return false
            }
            return path1 < path2
        })
    }

    func sortedDescending<T: Comparable>(by keyPath: KeyPath<Element, T?>) -> [Element] {
        sorted(by: {
            guard let path1 = $0[keyPath: keyPath], let path2 = $1[keyPath: keyPath] else {
                return false
            }
            return path1 > path2
        })
    }
}

// MARK: - String Helpers

/// - See: https://twitter.com/jckarter/status/1230987212730167296
extension String: Error {}

/// - See: https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string
public extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }
}

/// - See: https://www.swiftbysundell.com/posts/string-literals-in-swift
public extension String.StringInterpolation {
    mutating func appendInterpolation<T>(unwrapping optional: T?, or: String = "") {
        let string = optional.map { "\($0)" } ?? or
        appendLiteral(string)
    }
}

public extension String {
    func removingNewLine() -> String {
        guard !hasSuffix("\n") else {
            return String(dropLast())
        }
        return self
    }
}

// MARK: - Result Helpers

/// - See: https://stackoverflow.com/a/46863180
public typealias ResultCallback<T> = (Result<T, Error>) -> Void

public extension Result where Success == Void {
    static var success: Result {
        .success(())
    }
}

public extension Result where Failure == Error {
    func mapVoid() -> Result<Void, Error> {
        map { _ in }
    }
}

public extension Result where Success == Void, Failure == Error {
    func combined(with results: Self...) -> Self {
        Result {
            try get()
            try results.forEach {
                try $0.get()
            }
        }
    }
}

// MARK: - Random Helpers

public extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }
}

/// - See: https://www.hackingwithswift.com/example-code/language/how-to-split-an-integer-into-an-array-of-its-digits
public extension BinaryInteger {
    var digits: [Int] {
        String(describing: self).compactMap { Int(String($0)) }
    }
}

public extension BinaryInteger {
    /// Converts range from 0 to X.
    func convertRange(oldMax: Self, newMax: Self) -> Self {
        ((self * newMax) / oldMax)
    }

    /// Converts range from X to Y.
    func convertRange(oldMin: Self, oldMax: Self, newMin: Self, newMax: Self) -> Self {
        let oldRange, newRange, newValue: Self

        oldRange = (oldMax - oldMin)

        if oldRange == 0 {
            newValue = newMax
        } else {
            newRange = (newMax - newMin)
            newValue = (((self - oldMin) * newRange) / oldRange) + newMin
        }

        return newValue
    }
}

public extension FloatingPoint {
    /// Converts range from 0 to X.
    func convertRange(oldMax: Self, newMax: Self) -> Self {
        ((self * newMax) / oldMax)
    }

    /// Converts range from X to Y.
    func convertRange(oldMin: Self, oldMax: Self, newMin: Self, newMax: Self) -> Self {
        let oldRange, newRange, newValue: Self

        oldRange = (oldMax - oldMin)

        if oldRange == 0 {
            newValue = newMax
        } else {
            newRange = (newMax - newMin)
            newValue = (((self - oldMin) * newRange) / oldRange) + newMin
        }

        return newValue
    }
}

/// - See: https://stackoverflow.com/a/55122446/2165585
// swiftlint:disable force_unwrapping
public extension CaseIterable where Self: Equatable, AllCases: BidirectionalCollection {
    func previous() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let previous = all.index(before: idx)
        return all[previous < all.startIndex ? all.index(before: all.endIndex) : previous]
    }

    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}
// swiftlint:enable force_unwrapping
