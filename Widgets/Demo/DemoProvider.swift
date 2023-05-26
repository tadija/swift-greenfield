import WidgetKit

struct DemoProvider: TimelineProvider {
    func placeholder(in context: Context) -> DemoEntry {
        DemoEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DemoEntry) -> Void) {
        let entry = DemoEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DemoEntry>) -> Void) {
        var entries: [DemoEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            if let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) {
                let entry = DemoEntry(date: entryDate)
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DemoEntry: TimelineEntry {
    let date: Date
}
