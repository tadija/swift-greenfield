import SwiftUI

// MARK: - API

public extension Font {

    static func light(_ size: CGFloat, fixed: Bool = false) -> Font {
        fixed ? light.fixed(size) : light.dynamic(size)
    }

    static func regular(_ size: CGFloat, fixed: Bool = false) -> Font {
        fixed ? regular.fixed(size) : regular.dynamic(size)
    }

    static func bold(_ size: CGFloat, fixed: Bool = false) -> Font {
        fixed ? bold.fixed(size) : bold.dynamic(size)
    }

}

// MARK: - Constants

private extension Font {
    static let light = Custom(name: "Supreme-Light", ext: "otf")
    static let regular = Custom(name: "Supreme-Regular", ext: "otf")
    static let bold = Custom(name: "Supreme-Bold", ext: "otf")
}

// MARK: - Helpers

private extension Font {
    struct Custom: CustomStringConvertible {
        let name: String
        let ext: String

        var description: String {
            "\(name).\(ext)"
        }

        init(name: String, ext: String) {
            self.name = name
            self.ext = ext

            registerIfNeeded()
        }

        func dynamic(_ size: CGFloat) -> Font {
            Font.custom(name, size: size)
        }

        func fixed(_ size: CGFloat) -> Font {
            Font.custom(name, fixedSize: size)
        }

        private func registerIfNeeded() {
            let registeredFonts = CTFontManagerCopyAvailablePostScriptNames() as Array
            guard registeredFonts
                .compactMap({ $0 as? String })
                .contains(where: { $0 == name })
            else {
                register()
                return
            }
        }

        private func register() {
            guard let fontURL = Bundle.module.url(forResource: name, withExtension: ext) else {
                assertionFailure("missing font: \(description)")
                return
            }

            var error: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)

            if success {
                print("registered font: \(description)")
            } else {
                print("failed to register font: \(description)")
            }
        }
    }
}

// MARK: - View

public struct FontsView: View {
    public init() {}

    @State private var fontSize: Double = 24

    public var body: some View {
        fontList
            .navigationTitle("Fonts")
            .safeAreaInset(edge: .bottom) {
                fontSizeSlider
            }
    }

    private var fontList: some View {
        List {
            makeSection(Font.light)
            makeSection(Font.regular)
            makeSection(Font.bold)
        }
    }

    private func makeSection(_ font: Font.Custom) -> some View {
        Section(font.name) {
            Text("The quick brown fox jumps over the lazy dog \n🦊💫🐶")
                .font(font.dynamic(fontSize))
        }
    }

    private var fontSizeSlider: some View {
        VStack {
            Slider(value: $fontSize, in: 10...100, step: 1)
            Text("Font size: \(fontSize, specifier: "%.0f")")
                .font(.light(18))
        }
        .padding()
        .background(.regularMaterial)
    }
}

// MARK: - Previews

struct FontsView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(macOS)
        macOS
        #else
        iOS
        #endif
    }

    static var macOS: some View {
        FontsView()
            .previewLayout(.fixed(width: 400, height: 600))
    }

    static var iOS: some View {
        NavigationView {
            FontsView()
        }
    }
}
