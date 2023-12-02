import Shared
import SwiftUI

public struct HelloView: View {

    public init() {}

    public var body: some View {
        content.navigationTitle("Hello")
    }

    private var content: some View {
        VStack {
            Text(L10n.helloWorld)
                .font(.custom(.largeTitle))
                .background(Color.semantic(.tintPrimary))
                .foregroundColor(.semantic(.backPrimary))

            Asset.minion.swiftUIImage
                .resizable()
                .scaledToFit()
        }
        .padding(.vertical)
    }
}

// MARK: - Previews

#Preview {
    HelloView()
}
