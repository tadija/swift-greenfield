import SwiftUI

@Observable
public final class Navigation {

    public enum Layout: String, CaseIterable {
        case tabs, stack, split
    }

    public var layout: Layout
    public var routes: [Route]

    var tabSelection: Route?
    var stackPath: NavigationPath = .init()
    var splitSelection: Route?

    public init(
        layout: Layout = .tabs,
        routes: [Route] = Route.allCases
    ) {
        self.layout = layout
        self.routes = routes
    }

    public func toggleRoute(_ route: Route) {
        if routes.contains(route) {
            routes.removeAll(where: { $0 == route })
        } else {
            routes.append(route)
        }
    }

}

// MARK: - Routes

public enum Route: Hashable, CaseIterable {
    case hello
    case debug
    case camera
    case disk
    case networking
}

// MARK: - Label

public extension Route {
    var title: String {
        switch self {
        case .hello:
            "Hello"
        case .debug:
            "Debug"
        case .camera:
            "Camera"
        case .disk:
            "Disk"
        case .networking:
            "Networking"
        }
    }

    var symbol: String {
        switch self {
        case .hello:
            "hand.wave"
        case .debug:
            "gear"
        case .camera:
            "camera"
        case .disk:
            "internaldrive"
        case .networking:
            "network"
        }
    }
}

// MARK: - Factory

public extension Route {
    func makeLabel() -> some View {
        Label(title, systemImage: symbol)
    }

    @ViewBuilder
    func makeDestination() -> some View {
        switch self {
        case .hello:
            HelloView()
        case .debug:
            DebugView()
        case .camera:
            CameraView()
        case .disk:
            DiskView()
        case .networking:
            NetworkingView()
        }
    }
}
