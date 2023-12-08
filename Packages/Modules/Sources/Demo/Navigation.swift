import Minions
import SwiftUI

@Observable
public final class Navigation {

    public enum Layout: String, CaseIterable {
        case tabs, stack, split

        @DefaultsRaw(key: "Demo.Navigation.Layout")
        public static var `default`: Layout = .tabs
    }

    public var layout: Layout {
        didSet {
            if layout != oldValue {
                Layout.default = layout
            }
        }
    }

    public var routes: [Route]

    var tabSelection: Route? {
        didSet {
            if tabSelection == oldValue {
                tabSelection = nil
            }
        }
    }

    var stackPath: NavigationPath = .init()

    var splitSelection: Route?

    public init(
        layout: Layout = .default,
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

    public var showToolbar: Bool {
        #if os(iOS)
        switch layout {
        case .tabs:
            tabSelection == nil
        case .stack:
            stackPath.isEmpty
        case .split:
            splitSelection == nil
        }
        #else
        return true
        #endif
    }

}
