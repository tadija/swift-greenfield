import SwiftUI
import TopLevel
import WidgetKit

struct ExampleWidget: Widget {
    static var id: String {
        String(describing: self)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: Self.id,
            provider: ExampleProvider()
        ) { entry in
            ExampleEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ExampleEntryView: View {
    var entry: ExampleProvider.Entry

    var body: some View {
        VStack {
            Text(L10n.helloWorld)

            Image(systemName: "globe")
                .foregroundColor(Color("AccentColor"))
                .padding(.vertical)

            Text(entry.date, style: .time)
        }
    }
}

struct ExampleWidget_Previews: PreviewProvider {
    static var previews: some View {
        ExampleEntryView(entry: ExampleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
