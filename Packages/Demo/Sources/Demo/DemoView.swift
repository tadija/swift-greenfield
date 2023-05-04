import Shared
import SwiftUI
import Utils

public struct DemoView: View {
    public init() {}

    public var body: some View {
        VStack {
            Text(L10n.helloWorld)
                .font(.bold(40))

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.semantic(.tintPrimary))
                .padding()

            Text(envDescription)
                .font(.regular(18))
                .padding()
        }
        .padding()
    }

    var envDescription: String {
        Env().customDescription
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
