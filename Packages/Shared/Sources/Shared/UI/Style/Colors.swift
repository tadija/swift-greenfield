import SwiftUI
import Utils

// MARK: - API

public extension Color {

    enum Semantic: String, CaseIterable {
        case backPrimary
        case contentPrimary
        case tintPrimary
    }

    static func semantic(_ semantic: Semantic) -> Self {
        guard
            let lightColor = lightTheme[semantic],
            let darkColor = darkTheme[semantic]
        else {
            assertionFailure("missing color for key: \(semantic)")
            return .red
        }
        return Adaptive(light: lightColor, dark: darkColor)()
    }

}

// MARK: - Helpers

private extension Color {
    typealias Theme = [Semantic: Color]

    static let lightTheme: Theme = [
        .backPrimary: palette(.white),
        .contentPrimary: palette(.black),
        .tintPrimary: palette(.green)
    ]

    static let darkTheme: Theme = [
        .backPrimary: palette(.black),
        .contentPrimary: palette(.white),
        .tintPrimary: palette(.green)
    ]

    static func palette(_ key: ColorPalette) -> Self {
        Color(hex: key.rawValue)
    }
}

private enum ColorPalette: String, CaseIterable {
    case white = "#FFFFFF"
    case white90 = "#F5F5F5"
    case gray50 = "#D3D3D3"
    case gray = "#808080"
    case green = "#56D437"
    case black = "#000000"
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
                .font(.light(28))

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
            ForEach(ColorPalette.allCases, id: \.rawValue) { key in
                VStack {
                    ColorSquare(color: .palette(key))

                    Text(key.rawValue)
                        .font(.bold(12))
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
            .font(.bold(18))

            ForEach(Color.Semantic.allCases, id: \.rawValue) { color in
                HStack {
                    ColorSquare(color: .semantic(color))
                        .colorScheme(.light)

                    Spacer()
                    Text(color.rawValue)
                        .font(.bold(16))
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
        NavigationView {
            ColorsView()
        }
        .previewLayout(.fixed(width: 375, height: 900))
    }
}
