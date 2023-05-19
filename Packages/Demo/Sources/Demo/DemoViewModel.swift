import Minions
import Shared
import SwiftUI

public final class DemoViewModel: ObservableObject {

    @Dependency(\.demo) var demo

    var currentContext: String {
        demo.currentContext
    }

    var environmentDescription: String {
        demo.env.description
    }

}

// MARK: - DemoDependency

protocol DemoDependency {
    var env: Env { get }

    var currentContext: String { get }
}

final class LiveDemoDependency: DemoDependency {
    @Dependency(\.env) var env

    var currentContext: String {
        "live"
    }
}

final class PreviewDemoDependency: DemoDependency {
    @Dependency(\.env) var env

    var currentContext: String {
        "preview"
    }
}

final class TestDemoDependency: DemoDependency {
    @Dependency(\.env) var env

    var currentContext: String {
        "test"
    }
}

struct DemoDependencyKey: DependencyKey {
    static var liveValue: DemoDependency = LiveDemoDependency()
    static var previewValue: DemoDependency = PreviewDemoDependency()
    static var testValue: DemoDependency = TestDemoDependency()
}

extension Dependencies {
    var demo: DemoDependency {
        get { Self[DemoDependencyKey.self] }
        set { Self[DemoDependencyKey.self] = newValue }
    }
}
