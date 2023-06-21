import Shared
import SwiftUI

public struct DemoView: View {

    public init(customTab: DemoTab? = nil) {
        let tabs = makeTabs(with: customTab)
        guard tabs.isNotEmpty else { fatalError("tabs cannot be empty")}

        allTabs = tabs
        selectedTab = customTab ?? tabs[0]
    }

    @State private var allTabs: [DemoTab]
    @State private var selectedTab: DemoTab

    public var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(allTabs) { tab in
                tab.content
                    .tabItem(tab.makeLabel)
                    .tag(tab)
            }
        }
        .tint(.semantic(.tintPrimary))
        #if os(macOS)
            // fix toolbar height on macOS
            .toolbar { ToolbarItem { ProgressView().opacity(0) } }
        #endif
    }
}

// MARK: - DemoTab

public struct DemoTab: Identifiable {
    public let id = UUID().uuidString

    var title: String
    var systemImage: String
    var content: AnyView

    public init<T: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: @escaping () -> T
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = AnyView(content())
    }

    func makeLabel() -> some View {
        Label(title, systemImage: systemImage)
    }
}

extension DemoTab: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: DemoTab, rhs: DemoTab) -> Bool {
        lhs.id == rhs.id
    }
}

extension DemoTab {
    static var debug: Self {
        .init(title: "Debug", systemImage: "gear") { DebugView() }
    }

    static var camera: Self {
        .init(title: "Camera", systemImage: "camera") { CameraView() }
    }

    static var disk: Self {
        .init(title: "Disk", systemImage: "internaldrive") { DiskView() }
    }

    static var networking: Self {
        .init(title: "Networking", systemImage: "network") { NetworkingView() }
    }
}

private func makeTabs(with customTab: DemoTab?) -> [DemoTab] {
    let demoTabs: [DemoTab] = [.debug, .camera, .disk, .networking]

    if let customTab {
        return [customTab] + demoTabs
    } else {
        return demoTabs
    }
}

// MARK: - Previews

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
