import Minions
import SwiftUI

// MARK: - Custom Fonts

public extension Font {
    static let light = Custom(file: "Supreme-Light.otf", bundle: .module)
    static let regular = Custom(file: "Supreme-Regular.otf", bundle: .module)
    static let bold = Custom(file: "Supreme-Bold.otf", bundle: .module)
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
        Section(font.description) {
            Text("The quick brown fox jumps over the lazy dog \n🦊💫🐶")
                .font(font(fontSize))
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
