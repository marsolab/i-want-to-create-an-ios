import SwiftUI
import WidgetKit

extension AffirmationEntry: TimelineEntry {}

struct DailyAffirmationProvider: TimelineProvider {
    func placeholder(in context: Context) -> AffirmationEntry {
        sample
    }

    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        if context.isPreview {
            completion(sample)
        } else {
            completion(entries().first!)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        let now = Date()
        completion(
            Timeline(
                entries: AffirmationTimeline.entries(from: now, membership: WidgetMembershipStore().read()),
                policy: .after(AffirmationTimeline.reloadDate(from: now))
            )
        )
    }

    private func entries() -> [AffirmationEntry] {
        AffirmationTimeline.entries(from: Date(), membership: WidgetMembershipStore().read())
    }

    private var sample: AffirmationEntry {
        AffirmationEntry(date: Date(), affirmation: DailyAffirmationCatalog.all[0])
    }
}

@main
struct DailyAffirmationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetMembershipStore.widgetKind, provider: DailyAffirmationProvider()) { entry in
            DailyAffirmationWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily affirmation")
        .description("A gentle daily reflection on patience, gratitude, and trust in Allah. Membership required.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct DailyAffirmationWidgetView: View {
    let entry: AffirmationEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        AffirmationWidgetCard(affirmation: entry.affirmation, family: family)
            .containerBackground(for: .widget) {
                PrayerTheme.canvas
            }
            .widgetURL(URL(string: "prayerfocus://daily-affirmation"))
    }
}

#Preview(as: .systemSmall) {
    DailyAffirmationWidget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: DailyAffirmationCatalog.all[14])
    AffirmationEntry(date: .now, affirmation: nil)
}

#Preview(as: .systemMedium) {
    DailyAffirmationWidget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: DailyAffirmationCatalog.all[14])
}

#Preview(as: .accessoryRectangular) {
    DailyAffirmationWidget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: DailyAffirmationCatalog.all[14])
}
