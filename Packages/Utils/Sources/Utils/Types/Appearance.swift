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

#endif

#if canImport(SwiftUI)

import SwiftUI

// MARK: - ColorScheme

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

// MARK: - Color.Adaptive

extension Color {

    /// Resolves color based on the current interface style (Light / Dark).
    ///
    /// Usage example:
    ///
    ///     let color = Adaptive(light: light, dark: dark)()
    ///
    public struct Adaptive {

        public let light: Color
        public let dark: Color

        public init(light: Color, dark: Color) {
            self.light = light
            self.dark = dark
        }

        public func callAsFunction() -> Color {
            #if os(macOS)
            return Color(
                NSColor(name: nil) {
                    $0.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ?
                        NSColor(dark) : NSColor(light)
                }
            )
            #elseif canImport(UIKit)
            return Color(
                UIColor {
                    $0.isDark ?
                        UIColor(dark) : UIColor(light)
                }
            )
            #endif
        }

    }

}

// MARK: - Font.Custom

extension Font {

    /// Helper for auto registering custom font files from Swift package resources.
    ///
    /// Usage example:
    ///
    ///     extension Font {
    ///         static let light = Custom(file: "LightFont.otf", bundle: .module)
    ///         static let bold = Custom(file: "BoldFont.otf", bundle: .module)
    ///     }
    ///
    ///     Text("Dynamic Type")
    ///         .font(.light(21))
    ///
    ///     Text("Fixed Size")
    ///         .font(.bold(8, fixed: true))
    ///
    public struct Custom: CustomStringConvertible {

        public let file: String
        public let bundle: Bundle

        public var description: String {
            fontName
        }

        public init(file: String, bundle: Bundle) {
            self.file = file
            self.bundle = bundle

            registerIfNeeded()
        }

        // MARK: API

        public func callAsFunction(_ size: CGFloat, fixed: Bool = false) -> Font {
            fixed ? .custom(fontName, fixedSize: size) : .custom(fontName, size: size)
        }

        // MARK: Helpers

        private var fileComponents: [String] {
            file.components(separatedBy: ".")
        }

        private var fontName: String {
            fileComponents.first ?? ""
        }

        private var fontExtension: String {
            fileComponents.last ?? ""
        }

        private func registerIfNeeded() {
            let registeredFonts = CTFontManagerCopyAvailablePostScriptNames() as Array
            guard registeredFonts
                .compactMap({ $0 as? String })
                .contains(where: { $0 == fontName })
            else {
                register()
                return
            }
        }

        private func register() {
            guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
                print("❌ missing font: \(file)")
                return
            }

            var error: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)

            if success {
                print("ℹ️ registered font: \(file)")
            } else {
                print("⚠️ failed to register font: \(file)")
            }
        }

    }

}

#endif
