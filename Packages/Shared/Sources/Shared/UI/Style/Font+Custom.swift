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
            .custom(.regular, size: 34, relativeTo: style)
        case .title:
            .custom(.regular, size: 28, relativeTo: style)
        case .title2:
            .custom(.bold, size: 24, relativeTo: style)
        case .title3:
            .custom(.light, size: 22, relativeTo: style)
        case .headline:
            .custom(.bold, size: 20, relativeTo: style)
        case .subheadline:
            .custom(.light, size: 18, relativeTo: style)
        case .body:
            .custom(.regular, size: 17, relativeTo: style)
        case .callout:
            .custom(.bold, size: 16, relativeTo: style)
        case .caption:
            .custom(.regular, size: 15, relativeTo: style)
        case .caption2:
            .custom(.bold, size: 14, relativeTo: style)
        case .footnote:
            .custom(.light, size: 13, relativeTo: style)
        @unknown default:
            .custom(.regular, size: 17, relativeTo: style)
        }
    }
}

// MARK: - Helpers

private extension Font.Custom {
    var font: FontConvertible {
        switch self {
        case .light:
            FontFamily.Supreme.light
        case .regular:
            FontFamily.Supreme.regular
        case .bold:
            FontFamily.Supreme.bold
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

#Preview {
    NavigationStack {
        FontsView()
    }
}
