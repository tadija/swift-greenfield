import Utils

/// TopLevel namespace
public enum TopLevel {}

// MARK: - Custom

public extension TopLevel {

    /// Custom environment
    static let env = Env()

    /// Custom environment description
    static var envDescription: String {
        env.customDescription
    }

}
