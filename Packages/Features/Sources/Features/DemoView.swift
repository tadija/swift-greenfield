import Shared
import SwiftUI

public struct DemoView: View {
    @StateObject var vm = DemoViewModel()

    public init() {}

    public var body: some View {
        VStack {
            Text(L10n.helloWorld)
                .font(.bold(40))

            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.semantic(.tintPrimary))

                Text(vm.currentContext)
                    .font(.regular(24))
            }
            .padding()

            Text(vm.environmentDescription)
                .font(.light(16))
                .padding()
        }
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
