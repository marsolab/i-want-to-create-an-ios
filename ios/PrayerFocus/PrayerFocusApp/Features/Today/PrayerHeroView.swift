import SwiftUI

struct PrayerHeroView: View {
    let prayer: Prayer
    let phase: PrayerSessionPhase
    let selectedItemCount: Int
    let isAuthorized: Bool
    var topSafeAreaInset: CGFloat = 0
    let settingsAction: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var prayerNameSize = 50.0

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                Image("ArchMosque")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: PrayerTheme.canvas.opacity(0.90), location: 0),
                        .init(color: Color.white.opacity(0.48), location: 0.18),
                        .init(color: Color.white.opacity(0.18), location: 0.48),
                        .init(color: Color.clear, location: 0.78),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 28,
                    bottomTrailingRadius: 28,
                    style: .continuous
                )
            )

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button(action: settingsAction) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(PrayerTheme.ink)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .accessibilityLabel("Open settings")
                    .accessibilityIdentifier("today.settings")
                }
                .padding(16)
                .padding(.top, topSafeAreaInset)

                VStack(spacing: 10) {
                    Text("It’s time for")
                        .font(.title3.weight(.medium))

                    Text(prayer.displayName)
                        .font(.system(size: prayerNameSize, weight: .bold, design: .default))
                        .tracking(-1.2)
                        .minimumScaleFactor(0.75)

                    Text("Take a pause from the world\nand turn to Allah.")
                        .font(.body)
                        .foregroundStyle(PrayerTheme.secondaryInk)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .foregroundStyle(PrayerTheme.ink)
                .padding(.top, 18)

                Spacer(minLength: 130)
            }

            FocusStatusCard(
                phase: phase,
                selectedItemCount: selectedItemCount,
                isAuthorized: isAuthorized
            )
            .padding(.horizontal, 24)
            .offset(y: 26)
        }
        .frame(height: 500 + topSafeAreaInset)
        .accessibilityElement(children: .contain)
    }
}

private struct FocusStatusCard: View {
    let phase: PrayerSessionPhase
    let selectedItemCount: Int
    let isAuthorized: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(PrayerTheme.sage, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(PrayerTheme.ink)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(PrayerTheme.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(.ultraThickMaterial)
        .clipShape(Capsule(style: .continuous))
        .shadow(color: PrayerTheme.ink.opacity(0.12), radius: 18, y: 8)
    }

    private var iconName: String {
        switch phase {
        case .ready: selectedItemCount == 0 ? "plus" : "pause.fill"
        case .inProgress: "moon.stars.fill"
        case .checkedIn: "checkmark"
        case .unlocked: "lock.open.fill"
        }
    }

    private var title: String {
        switch phase {
        case .ready:
            selectedItemCount == 0
                ? "Choose distracting apps" : "\(selectedItemCount) items selected"
        case .inProgress: "Prayer check-in started"
        case .checkedIn: "Prayer checked in"
        case .unlocked: "Focus unlocked"
        }
    }

    private var detail: String {
        switch phase {
        case .ready:
            if selectedItemCount == 0 {
                return "Set up Screen Time in Settings."
            }
            return isAuthorized
                ? "Ready for device validation." : "Screen Time permission is needed."
        case .inProgress:
            return "Put your phone away when you’re ready."
        case .checkedIn:
            return "Saved privately on this device."
        case .unlocked:
            return "No prayer completion was recorded."
        }
    }
}

#Preview {
    PrayerHeroView(
        prayer: .dhuhr,
        phase: .ready,
        selectedItemCount: 3,
        isAuthorized: true,
        settingsAction: {}
    )
    .background(PrayerTheme.canvas)
}
