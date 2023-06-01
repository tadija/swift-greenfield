import Minions
import SwiftUI

// MARK: - API

public extension Color {

    enum Semantic: String, CaseIterable {
        case backPrimary
        case backSecondary
        case contentPrimary
        case contentSecondary
        case tintPrimary
    }

    static func semantic(_ semantic: Semantic) -> Self {
        guard
            let lightColor = lightTheme[semantic]?.swiftuiColor,
            let darkColor = darkTheme[semantic]?.swiftuiColor
        else {
            assertionFailure("missing color for key: \(semantic)")
            return .red
        }
        return Adaptive(light: lightColor, dark: darkColor)()
    }

}

// MARK: - Helpers

private extension Color {
    typealias Theme = [Semantic: PaletteColor]

    static let lightTheme: Theme = [
        .backPrimary: .white,
        .backSecondary: .gray10,
        .contentPrimary: .black,
        .contentSecondary: .gray60,
        .tintPrimary: .greenLight
    ]

    static let darkTheme: Theme = [
        .backPrimary: .black,
        .backSecondary: .gray90,
        .contentPrimary: .white,
        .contentSecondary: .gray20,
        .tintPrimary: .greenDark
    ]
}

private extension PaletteColor {
    static var allCases: [Self] {[
        .black,
        .white,
        .gray10,
        .gray20,
        .gray60,
        .gray90,
        .greenLight,
        .greenDark
    ]}

    var swiftuiColor: Color {
        RGBAColor(rgba: rgbaValue).toColor()
    }

    var hex: String {
        color.cgColor.toHex()
    }
}

// MARK: - View

public struct ColorsView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            content
        }
        .background(background)
        .navigationTitle("Colors")
    }

    private var background: some View {
        Color.gray
            .edgesIgnoringSafeArea(.bottom)
    }

    private var content: some View {
        VStack(alignment: .leading) {
            makeSection("Palette") {
                colorPaletteGrid
            }

            makeSection("Semantic Colors") {
                colorSemanticList
            }
        }
        .padding()
    }

    private func makeSection<T: View>(_ title: String, content: () -> T) -> some View {
        VStack {
            Text(title)
                .font(.custom(.title))

            content()
        }
        .padding(.vertical)
    }

    private var colorPaletteGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]) {
            ForEach(PaletteColor.allCases, id: \.rgbaValue) { paletteColor in
                VStack {
                    ColorSquare(color: paletteColor.swiftuiColor)

                    Text(paletteColor.hex)
                        .font(.custom(.footnote))
                }
            }
        }
    }

    private var colorSemanticList: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Light")
                Spacer()
                Text("Dark")
            }
            .font(.custom(.headline))

            ForEach(Color.Semantic.allCases, id: \.rawValue) { color in
                HStack {
                    ColorSquare(color: .semantic(color))
                        .colorScheme(.light)

                    Spacer()
                    Text(color.rawValue)
                        .font(.custom(.caption2))
                    Spacer()

                    ColorSquare(color: .semantic(color))
                        .colorScheme(.dark)
                }
            }
        }
    }

    private struct ColorSquare: View {
        var color: Color

        var body: some View {
            color
                .frame(width: 80, height: 80)
                .cornerRadius(6)
        }
    }
}

struct ColorsView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(macOS)
        macOS
        #else
        iOS
        #endif
    }

    static var macOS: some View {
        ColorsView()
            .previewLayout(.fixed(width: 400, height: 800))
    }

    static var iOS: some View {
        NavigationStack {
            ColorsView()
        }
        .previewLayout(.fixed(width: 375, height: 900))
    }
}
