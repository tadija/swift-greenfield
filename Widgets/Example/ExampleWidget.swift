import SwiftUI
import WidgetKit

struct ExampleWidget: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExampleProvider()) { entry in
            ExampleEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ExampleEntryView: View {
    var entry: ExampleProvider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

struct ExampleWidget_Previews: PreviewProvider {
    static var previews: some View {
        ExampleEntryView(entry: ExampleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
