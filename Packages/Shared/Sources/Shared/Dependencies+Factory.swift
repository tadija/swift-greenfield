import Minions

// MARK: - Build Config

extension BuildConfig: DependencyKey {
    public static var liveValue = BuildConfig()
}

extension Dependencies {
    public var buildConfig: BuildConfig {
        get { Self[BuildConfig.self] }
        set { Self[BuildConfig.self] = newValue }
    }
}

// MARK: - Device

extension Device: DependencyKey {
    public static var liveValue = Device()
}

extension Dependencies {
    public var device: Device {
        get { Self[Device.self] }
        set { Self[Device.self] = newValue }
    }
}

// MARK: - Version

extension Version: DependencyKey {
    static let bundleVersion = Dependencies[\.buildConfig].bundleVersion

    public static var liveValue = Version(bundleVersion)
}

extension Dependencies {
    public var version: Version {
        get { Self[Version.self] }
        set { Self[Version.self] = newValue }
    }
}

// MARK: - Env

extension Env: DependencyKey {
    public static var liveValue = Env()
}

extension Dependencies {
    public var env: Env {
        get { Self[Env.self] }
        set { Self[Env.self] = newValue }
    }
}
