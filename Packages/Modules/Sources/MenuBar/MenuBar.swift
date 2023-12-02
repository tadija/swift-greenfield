#if os(macOS)

import SwiftUI

public struct MenuBarItem {
    public var title: String
    public var action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

@Observable
public final class MenuBarModel {
    var sections: [String: [MenuBarItem]]

    public init(sections: [String: [MenuBarItem]] = [:]) {
        self.sections = sections
    }

    var aboutItem = MenuBarItem(title: "About") {
        NSApp.orderFrontStandardAboutPanel()
    }

    var quitItem = MenuBarItem(title: "Quit") {
        NSApp.terminate(nil)
    }
}

public struct MenuBarView: View {
    @State private var model: MenuBarModel

    public init(sections: [String: [MenuBarItem]]) {
        model = .init(sections: sections)
    }

    public var body: some View {
        ForEach(Array(model.sections.keys), id: \.self) { key in
            Menu(key) {
                if let items = model.sections[key] {
                    ForEach(items, id: \.title) { item in
                        Button(item.title, action: item.action)
                    }
                }
            }
        }

        Divider()

        let about = model.aboutItem
        Button(about.title, action: about.action)

        let quit = model.quitItem
        Button(quit.title, action: quit.action)
    }
}

#endif
