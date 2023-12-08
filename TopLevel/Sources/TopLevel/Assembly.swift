import Demo
import MenuBar
import SwiftUI

// MARK: - Assembly

public final class Assembly {

    public init() {}

    private lazy var demo = Demo.Navigation(routes: [
        .hello, .debug, .files, .camera, .trending, .chat
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

        items.append(contentsOf: Demo.Route.allCases.map { route in
            .init(title: route.title) {
                let windowSize = CGSize(width: 400, height: 600)
                NSWindow.open(route.title, size: windowSize) {
                    NavigationStack {
                        route.makeDestination()
                    }
                }
            }
        })

        let title = "Content"
        items.append(.init(title: title, action: {
            NSWindow.open(title) {
                Demo.ContentView()
            }
        }))

        return items
    }
}

#endif

// MARK: - Previews

#Preview("App") {
    Assembly().appView()
}
