import WidgetKit

struct ExampleProvider: TimelineProvider {
    func placeholder(in context: Context) -> ExampleEntry {
        ExampleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ExampleEntry) -> Void) {
        let entry = ExampleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ExampleEntry>) -> Void) {
        var entries: [ExampleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            if let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) {
                let entry = ExampleEntry(date: entryDate)
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ExampleEntry: TimelineEntry {
    let date: Date
}
