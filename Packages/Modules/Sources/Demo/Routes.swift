import SwiftUI

public enum Route: Hashable, CaseIterable {
    case hello
    case debug
    case files
    case camera
    case trending
    case chat
}

// MARK: - Label

public extension Route {
    var title: String {
        switch self {
        case .hello:
            "Hello"
        case .debug:
            "Debug"
        case .files:
            "Files"
        case .camera:
            "Camera"
        case .trending:
            "Trending"
        case .chat:
            "Chat"
        }
    }

    var symbol: String {
        switch self {
        case .hello:
            "hand.wave"
        case .debug:
            "gear"
        case .files:
            "internaldrive"
        case .camera:
            "camera"
        case .trending:
            "network"
        case .chat:
            "message"
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
        case .files:
            FilesView()
        case .camera:
            CameraView()
        case .trending:
            TrendingView()
        case .chat:
            ChatView()
        }
    }
}
