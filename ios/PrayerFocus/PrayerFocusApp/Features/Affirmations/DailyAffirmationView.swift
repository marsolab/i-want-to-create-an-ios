import SwiftUI
import WidgetKit

struct DailyAffirmationView: View {
    private let previewAffirmation: DailyAffirmation?

    init(previewAffirmation: DailyAffirmation? = nil) {
        self.previewAffirmation = previewAffirmation
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let affirmation = previewAffirmation ?? DailyAffirmationCatalog.affirmation(on: context.date)
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    reflection(affirmation)
                    widgetGuide(affirmation)
                    installationInstructions
                }
                .padding(PrayerTheme.pageMargin)
                .padding(.bottom, 12)
            }
            .background(PrayerTheme.canvas.ignoresSafeArea())
        }
        .navigationTitle("Daily affirmation")
        .navigationBarTitleDisplayMode(.inline)
        .tint(PrayerTheme.sage)
    }

    private func reflection(_ affirmation: DailyAffirmation) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: "moon")
                    .font(.system(size: 22, weight: .light))
                Spacer()
                Text(affirmation.theme)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(PrayerTheme.sage)

            Text(affirmation.text)
                .font(.system(.largeTitle, design: .serif).weight(.medium))
                .foregroundStyle(PrayerTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("affirmation.text")

            Text("An original reflection")
                .font(.caption)
                .foregroundStyle(PrayerTheme.secondaryInk)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .prayerCard()
    }

    private func widgetGuide(_ affirmation: DailyAffirmation) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("A little reminder, close by")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(PrayerTheme.ink)
                Text("The same daily reflection, wherever you pause.")
                    .font(.subheadline)
                    .foregroundStyle(PrayerTheme.secondaryInk)
            }

            VStack(alignment: .leading, spacing: 10) {
                widgetPreview(affirmation, family: .systemSmall)
                    .frame(width: 164, height: 164)
                    .accessibilityIdentifier("affirmation.preview.small")
                previewLabel("Home Screen · small")
            }

            VStack(alignment: .leading, spacing: 10) {
                widgetPreview(affirmation, family: .systemMedium)
                    .frame(height: 164)
                    .accessibilityIdentifier("affirmation.preview.medium")
                previewLabel("Home Screen · medium")
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    AffirmationWidgetCard(affirmation: affirmation, family: .accessoryRectangular)
                        .environment(\.widgetRenderingMode, .vibrant)
                        .environment(\.colorScheme, .dark)
                        .frame(width: 160, height: 64)
                    Spacer()
                    Image(systemName: "moon")
                        .font(.system(size: 28, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.65))
                        .accessibilityHidden(true)
                }
                .padding(18)
                .background(PrayerTheme.sageDark, in: RoundedRectangle(cornerRadius: 20))
                .accessibilityIdentifier("affirmation.preview.lockScreen")
                previewLabel("Lock Screen · rectangular")
            }
        }
    }

    private func widgetPreview(_ affirmation: DailyAffirmation, family: WidgetFamily) -> some View {
        AffirmationWidgetCard(affirmation: affirmation, family: family)
            .padding(16)
            .background(PrayerTheme.canvas, in: RoundedRectangle(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(PrayerTheme.hairline.opacity(0.8), lineWidth: 1)
            }
    }

    private func previewLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(PrayerTheme.secondaryInk)
    }

    private var installationInstructions: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Add your widget")
                .font(.title3.weight(.semibold))

            instruction(
                title: "Home Screen",
                icon: "square.grid.2x2",
                detail:
                    "Touch and hold an empty area on your Home Screen. Tap Edit, then Add Widget. Find Prayer Focus, choose a size, and tap Add Widget."
            )
            instruction(
                title: "Lock Screen",
                icon: "lock.rectangle",
                detail:
                    "Touch and hold your Lock Screen, then tap Customize and select Lock Screen. Tap the widget area below the clock and choose Prayer Focus."
            )

            Text("A new reflection each day. Your reflections are available offline with an active membership.")
                .font(.footnote)
                .foregroundStyle(PrayerTheme.secondaryInk)
        }
        .foregroundStyle(PrayerTheme.ink)
    }

    private func instruction(title: String, icon: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(PrayerTheme.sage)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(PrayerTheme.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct DailyAffirmationSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DailyAffirmationView()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        DailyAffirmationView(previewAffirmation: DailyAffirmationCatalog.all[14])
    }
}
