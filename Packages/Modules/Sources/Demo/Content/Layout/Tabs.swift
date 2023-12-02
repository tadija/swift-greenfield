import Shared
import SwiftUI

public struct TabsView: View {
    @Environment(Navigation.self) private var navigation

    public init() {}

    public var body: some View {
        TabView(selection: Bindable(navigation).tabSelection) {
            content
        }
        .navigationTitle("Tabs")
        .tint(.semantic(.tintPrimary))
    }

    private var content: some View {
        ForEach(navigation.routes, id: \.self) { route in
            NavigationStack {
                route.makeDestination()
            }
            .tabItem { route.makeLabel() }
            .tag(Optional.some(route))
        }
    }
}

// MARK: - Previews

#Preview {
    TabsView()
        .environment(Navigation(layout: .tabs))
}
