import Demo
import Hello
import SwiftUI

public struct RootView: View {
    public init() {}

    public var body: some View {
        DemoView(customTab: .hello)
    }
}

extension DemoTab {
    static var hello: Self {
        .init(title: "Hello", systemImage: "hand.wave") {
            HelloView()
        }
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
