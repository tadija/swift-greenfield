import Minions
import SwiftUI

// MARK: - API

public extension Font {

    enum Custom: String, CaseIterable {
        case light
        case regular
        case bold
    }

    static func custom(_ custom: Custom, _ size: CGFloat) -> Self {
        custom.font.swiftUIFont(size: size)
    }

    static func custom(_ custom: Custom, fixed size: CGFloat) -> Self {
        custom.font.swiftUIFont(fixedSize: size)
    }

    static func custom(_ custom: Custom, size: CGFloat, relativeTo textStyle: TextStyle) -> Self {
        custom.font.swiftUIFont(size: size, relativeTo: textStyle)
    }

    static func custom(_ style: TextStyle) -> Self {
        switch style {
        case .largeTitle:
            return .custom(.regular, size: 34, relativeTo: style)
        case .title:
            return .custom(.regular, size: 28, relativeTo: style)
        case .title2:
            return .custom(.bold, size: 24, relativeTo: style)
        case .title3:
            return .custom(.light, size: 22, relativeTo: style)
        case .headline:
            return .custom(.bold, size: 20, relativeTo: style)
        case .subheadline:
            return .custom(.light, size: 18, relativeTo: style)
        case .body:
            return .custom(.regular, size: 17, relativeTo: style)
        case .callout:
            return .custom(.bold, size: 16, relativeTo: style)
        case .caption:
            return .custom(.regular, size: 15, relativeTo: style)
        case .caption2:
            return .custom(.bold, size: 14, relativeTo: style)
        case .footnote:
            return .custom(.light, size: 13, relativeTo: style)
        @unknown default:
            return .custom(.regular, size: 17, relativeTo: style)
        }
    }
}

// MARK: - Helpers

private extension Font.Custom {
    var font: FontConvertible {
        switch self {
        case .light:
            return FontFamily.Supreme.light
        case .regular:
            return FontFamily.Supreme.regular
        case .bold:
            return FontFamily.Supreme.bold
        }
    }
}

// MARK: - View

public struct FontsView: View {
    public init() {}

    @State private var fontSize: Double = 24

    public var body: some View {
        content
            .navigationTitle("Fonts")
            .safeAreaInset(edge: .bottom) {
                fontSizeSlider
            }
    }

    private var content: some View {
        List(Font.Custom.allCases, id: \.rawValue) {
            makeSection($0)
        }
    }

    private func makeSection(_ font: Font.Custom) -> some View {
        Section(font.rawValue) {
            Text("The quick brown fox jumps over the lazy dog \n🦊💫🐶")
                .font(.custom(font, fontSize))
        }
    }

    private var fontSizeSlider: some View {
        VStack {
            Slider(value: $fontSize, in: 10...100, step: 1)
            Text("Font size: \(fontSize, specifier: "%.0f")")
                .font(.custom(.callout))
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
        NavigationStack {
            FontsView()
        }
    }
}
