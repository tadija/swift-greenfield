import Foundation

/// Helper for utilizing dark / light / system appearance.
///
/// Example of a possible implementation:
///
///     @Published var appearance: Appearance = .system {
///         didSet {
///             appearance.apply(in: .keyWindow)
///         }
///     }
///
///     RootView().preferredColorScheme(appearance.colorScheme)
///
public enum Appearance: String, Identifiable, CaseIterable {
    case dark
    case light
    case system

    public var id: String {
        rawValue
    }
}

#if canImport(SwiftUI)

import SwiftUI

public extension Appearance {
    var colorScheme: ColorScheme? {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return nil
        }
    }
}

#endif

#if os(iOS) || os(tvOS)

import UIKit

public extension Appearance {
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return .unspecified
        }
    }

    var isDark: Bool {
        guard self == .system else {
            return self == .dark
        }
        return UITraitCollection.current.isDark
    }

    var isLight: Bool {
        !isDark
    }

    func apply(in window: UIWindow?) {
        switch self {
        case .dark:
            window?.overrideUserInterfaceStyle = .dark
        case .light:
            window?.overrideUserInterfaceStyle = .light
        case .system:
            window?.overrideUserInterfaceStyle = .unspecified
        }
    }
}

public extension UITraitCollection {
    var isDark: Bool {
        userInterfaceStyle == .dark
    }
}

public extension Color {
    static func dynamic(light: Color, dark: Color) -> Color {
        Color(
            UIColor(
                dynamicProvider: {
                    $0.isDark ? UIColor(dark) : UIColor(light)
                }
            )
        )
    }
}

#endif
