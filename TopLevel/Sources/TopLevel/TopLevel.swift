import Features
import SwiftUI

/// TopLevel namespace
public enum TopLevel {}

// MARK: - Custom

public extension TopLevel {

    static func makeAppView() -> some View {
        RootView()
    }

}
