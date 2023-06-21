import Shared
import SwiftUI

public struct HelloView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            content.navigationTitle("GreenField Demo")
        }
    }

    private var content: some View {
        VStack {
            Text(L10n.helloWorld)
                .font(.custom(.largeTitle))
                .background(Color.semantic(.tintPrimary))
                .foregroundColor(.semantic(.backPrimary))

            Asset.minion.swiftUIImage
        }
    }
}

// MARK: - Previews

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        HelloView()
    }
}
