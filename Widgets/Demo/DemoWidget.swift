import Shared
import SwiftUI
import WidgetKit

struct DemoWidget: Widget {
    static var id: String {
        String(describing: self)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: Self.id,
            provider: DemoProvider()
        ) { entry in
            DemoEntryView(entry: entry)
        }
        .configurationDisplayName("Demo Widget")
        .description("This is a widget demo.")
    }
}

struct DemoEntryView: View {
    var entry: DemoProvider.Entry

    var body: some View {
        VStack {
            Text(L10n.helloWorld)
                .font(.bold(20))

            Image(systemName: "globe")
                .foregroundColor(.semantic(.tintPrimary))
                .padding(.vertical)

            Text(entry.date, style: .time)
                .font(.light(20))
        }
    }
}

struct DemoWidget_Previews: PreviewProvider {
    static var previews: some View {
        DemoEntryView(entry: DemoEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
