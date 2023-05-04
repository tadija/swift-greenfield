import SwiftUI
import TopLevel

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            TopLevel.makeAppView()
        }
    }
}

struct App_Previews: PreviewProvider {
    static var previews: some View {
        TopLevel.makeAppView()
    }
}
