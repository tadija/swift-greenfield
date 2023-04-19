import SwiftUI
import TopLevel

struct AppView: View {
    var body: some View {
        VStack {
            Text(L10n.helloWorld)
                .font(.bold(40))

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .padding()

            Text(TopLevel.envDescription)
                .font(.regular(18))
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
