import Demo
import MenuBar
import SwiftUI

// MARK: - Assembly

public final class Assembly {

    public init() {}

    private lazy var demo = Demo.Navigation(routes: [
        .hello, .debug, .camera, .disk, .networking
    ])

}

// MARK: - App View

extension Assembly {
    public func appView() -> some View {
        Demo.ContentView(navigation: demo)
    }
}

// MARK: - Menu Bar App

#if os(macOS)

extension Assembly {
    public func appMenu() -> some View {
        MenuBarView(sections: [
            "Demo": demoItems()
        ])
    }

    private func demoItems() -> [MenuBarItem] {
        var items = [MenuBarItem]()
        items.append(
            contentsOf: Demo.Route.allCases.map { route in
                menuItem(for: route)
            }
        )
        items.append(.init(title: "Content", action: {
            NSWindow.open {
                Demo.ContentView()
            }
        }))
        return items
    }

    private func menuItem(for route: Demo.Route) -> MenuBarItem {
        .init(title: route.title) {
            NSWindow.open(size: CGSize(width: 400, height: 600)) {
                NavigationStack {
                    route.makeDestination()
                }
            }
        }
    }
}

#endif

// MARK: - Previews

#Preview("App") {
    Assembly().appView()
}
