import Shared
import SwiftUI

public struct ContentView: View {

    @Bindable private var navigation: Navigation

    public init(navigation: Navigation = .init()) {
        self.navigation = navigation
    }

    public var body: some View {
        content
            .environment(navigation)
            .toolbar {
                toolbarContent()
            }
            .tint(.semantic(.tintPrimary))
    }

    @ViewBuilder
    private var content: some View {
        switch navigation.layout {
        case .tabs:
            TabsView()
        case .stack:
            StackView()
        case .split:
            SplitView()
        }
    }

    private func toolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: toolbarItemPlacement) {
            toolbarLayout
            toolbarItems
        }
    }

    private var toolbarItemPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .bottomBar
        #else
        .primaryAction
        #endif
    }

    private var toolbarLayout: some View {
        Picker("Layout", selection: $navigation.layout) {
            ForEach(Navigation.Layout.allCases, id: \.self) { layout in
                Text(layout.rawValue.capitalized)
            }
        }
        .pickerStyle(.menu)
    }

    private var toolbarItems: some View {
        Menu(.init("Items")) {
            ForEach(Demo.Route.allCases, id: \.self) { route in
                Button(action: {
                    navigation.toggleRoute(route)
                }, label: {
                    HStack {
                        if navigation.routes.contains(route) {
                            Image(systemName: "checkmark.square.fill")
                        }
                        Text(route.title)
                    }
                })
            }
        }
    }
}

// MARK: - Previews

#Preview {
    ContentView()
}
