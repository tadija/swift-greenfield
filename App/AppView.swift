import SwiftUI
import TopLevel

struct AppView: View {
    var body: some View {
        VStack {
            Text(L10n.helloWorld)
                .font(.largeTitle)

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .padding()

            Text(TopLevel.envDescription)
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
