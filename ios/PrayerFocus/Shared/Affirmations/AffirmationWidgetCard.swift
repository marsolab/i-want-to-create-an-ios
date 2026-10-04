import SwiftUI
import WidgetKit

/// Content only: the system widget supplies its own container and margins.
struct AffirmationWidgetCard: View {
    let affirmation: DailyAffirmation?
    let family: WidgetFamily
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        Group {
            if family == .accessoryRectangular {
                lockScreen
            } else {
                homeScreen
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var homeScreen: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: "moon")
                        .font(.system(size: 11, weight: .semibold))
                        .widgetAccentable()
                    Text(affirmation == nil ? "DAILY REFLECTIONS" : "DAILY AFFIRMATION")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(0.6)
                }
                .foregroundStyle(accentColor)

                Spacer(minLength: 0)

                Text(affirmation?.text ?? "Open Prayer Focus to continue.")
                    .font(.system(size: family == .systemSmall ? 17 : 22, weight: .medium, design: .serif))
                    .foregroundStyle(textColor)
                    .lineLimit(family == .systemSmall ? 5 : 4)
                    .minimumScaleFactor(0.75)
                    .layoutPriority(1)

                Spacer(minLength: 0)

                HStack(spacing: 4) {
                    if affirmation == nil {
                        Image(systemName: "lock")
                    }
                    Text(affirmation?.theme ?? "Membership")
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(accentColor)
                .padding(.vertical, 3)
                .padding(.horizontal, 7)
                .background {
                    if renderingMode == .fullColor {
                        Capsule().fill(PrayerTheme.sageSoft)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if family == .systemMedium {
                arch
                    .frame(width: 52)
                    .accessibilityHidden(true)
            }
        }
    }

    private var lockScreen: some View {
        Text(affirmation?.text ?? "Daily reflections\nOpen Prayer Focus to continue.")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.primary)
            .lineLimit(3)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var arch: some View {
        UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28)
            .fill(renderingMode == .fullColor ? PrayerTheme.sageSoft : Color.primary.opacity(0.08))
            .overlay {
                UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28)
                    .stroke(accentColor.opacity(0.3), lineWidth: 1)
                    .padding(7)
            }
            .overlay {
                Image(systemName: "moon")
                    .font(.system(size: 19, weight: .light))
                    .foregroundStyle(accentColor)
                    .widgetAccentable()
            }
    }

    private var textColor: Color {
        renderingMode == .fullColor ? PrayerTheme.ink : .primary
    }

    private var accentColor: Color {
        renderingMode == .fullColor ? PrayerTheme.sage : .primary
    }

    private var accessibilityText: String {
        if let affirmation {
            "Daily affirmation. \(affirmation.text) \(affirmation.theme)."
        } else {
            "Daily reflections. Open Prayer Focus to continue. Membership required."
        }
    }
}
