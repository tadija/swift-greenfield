import Common
import SwiftUI

struct AppView: View {
    var body: some View {
        VStack {
            Text(L10n.helloWorld)
                .font(.largeTitle)

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .padding()

            Text(env.customDescription)
                .padding()
        }
        .padding()
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
