import Shared
import SwiftUI

public struct SplitView: View {
    @Environment(Navigation.self) private var navigation

    public init() {}

    public var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .navigationTitle("Split")
        .tint(.semantic(.tintPrimary))
    }

    private var sidebar: some View {
        List(selection: Bindable(navigation).splitSelection) {
            Section("Demo") {
                ForEach(navigation.routes, id: \.self) { route in
                    route.makeLabel()
                }
            }
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let route = navigation.splitSelection {
            NavigationStack {
                route.makeDestination()
            }
        } else {
            ContentUnavailableView("Select item", systemImage: "sidebar.left")
        }
    }
}

// MARK: - Previews

#Preview {
    SplitView()
        .environment(Navigation(layout: .split))
}
