import Shared
import SwiftUI

public struct DebugView: View {

    public init() {}

    public var body: some View {
        content
            .navigationTitle("Debug")
            .navigationDestination(for: Route.self) { route in
                route.makeDestination()
            }
            .tint(.semantic(.tintPrimary))
    }

    private var content: some View {
        List {
            Section {
                makeLink("Environment", route: .environment)
            } header: {
                makeHeader("Info")
            }

            Section {
                makeLink("Colors", route: .colors)
                makeLink("Fonts", route: .fonts)
            } header: {
                makeHeader("Style")
            }

            Section {
                makeLink("Buttons", route: .buttons)
            } header: {
                makeHeader("Components")
            }
        }
    }

    private func makeHeader(_ title: String) -> some View {
        Text(title)
            .font(.custom(.caption2))
            .foregroundColor(.semantic(.tintPrimary))
    }

    private func makeLink(_ title: String, route: Route) -> some View {
        NavigationLink(value: route) {
            Text(title)
        }
        .font(.custom(.body))
        .padding(.vertical, 12)
    }

    fileprivate enum Route: Hashable {
        case environment
        case colors
        case fonts
        case buttons
    }
}

private extension DebugView.Route {
    @ViewBuilder
    func makeDestination() -> some View {
        switch self {
        case .environment:
            EnvironmentView()
        case .colors:
            ColorsView()
        case .fonts:
            FontsView()
        case .buttons:
            ButtonsView()
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        DebugView()
    }
}
