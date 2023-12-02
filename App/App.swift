import SwiftUI
import TopLevel

@main
struct App: SwiftUI.App {
    private let assembly = Assembly()

    var body: some Scene {
        WindowGroup {
            assembly.appView()
        }

        #if os(macOS)
        MenuBarExtra("GreenField") {
            assembly.appMenu()
        }
        #endif
    }
}

// MARK: - Previews

#Preview("App") {
    Assembly().appView()
}

#if os(macOS)
#Preview("Menu") {
    Assembly().appMenu()
}
#endif
