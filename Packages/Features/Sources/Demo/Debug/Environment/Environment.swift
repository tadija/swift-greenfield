import Minions
import Shared
import SwiftUI

public struct EnvironmentView: View {

    private let state: EnvironmentViewState

    public init(state: EnvironmentViewState = .init()) {
        self.state = state
    }

    public var body: some View {
        content.navigationTitle("Environment")
    }

    private var content: some View {
        List {
            Section("+ context") { makeRow("📱 \(state.contextDescription)", style: .headline) }
            Section("+ build config") { makeRow(state.buildConfigDescription) }
            Section("+ custom config") { makeRow(state.customConfigDescription) }
            Section("+ device info") { makeRow(state.deviceDescription) }
            Section("+ app version") { makeRow(state.versionDescription) }
        }
        .font(.custom(.caption2))

        #if os(iOS)
            .listStyle(.grouped)
        #endif
    }

    private func makeRow(_ content: String, style: Font.TextStyle = .caption) -> some View {
        Text(content).font(.custom(style))
    }
}

// MARK: - State

public struct EnvironmentViewState {
    @Dependency(\.env) private var env
    @Dependency(\.demo) private var demo

    public init() {}

    var buildConfigDescription: String { env.buildConfig.description }
    var customConfigDescription: String { env.config.description }
    var deviceDescription: String { env.device.description }
    var versionDescription: String { env.version.description }
    var contextDescription: String { demo.context }
}

// MARK: - Factory

private struct DemoDependency {
    var context: String
}

extension DemoDependency: DependencyKey {
    static var liveValue: Self = .init(context: "live")
    static var previewValue: Self = .init(context: "preview")
    static var testValue: Self = .init(context: "test")
}

extension Dependencies {
    fileprivate var demo: DemoDependency {
        get { Self[DemoDependency.self] }
        set { Self[DemoDependency.self] = newValue }
    }
}

// MARK: - Previews

struct EnvironmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EnvironmentView()
        }
    }
}
