import Shared
import SwiftUI

public struct DemoView: View {
    @StateObject var vm = DemoViewModel()

    public init() {}

    public var body: some View {
        VStack {
            Text(L10n.helloWorld)

            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.semantic(.tintPrimary))

                Text(vm.currentContext)
            }
            .padding()

            Text(vm.environmentDescription)
                .padding()
        }
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
