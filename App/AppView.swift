import SwiftUI
import Common

struct AppView: View {
    var body: some View {
        VStack {
            Text("hello_world")
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
