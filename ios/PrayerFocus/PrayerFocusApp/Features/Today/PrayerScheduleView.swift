import SwiftUI

struct PrayerScheduleView: View {
    let session: PrayerFocusSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today’s prayers")
                .font(.title2.weight(.bold))
                .foregroundStyle(PrayerTheme.ink)

            VStack(spacing: 0) {
                ForEach(Array(Prayer.allCases.enumerated()), id: \.element.id) { index, prayer in
                    PrayerRow(
                        prayer: prayer,
                        state: rowState(for: prayer),
                        time: session.schedule?.time(for: prayer)
                    )

                    if index < Prayer.allCases.count - 1 {
                        Divider()
                            .padding(.leading, 58)
                    }
                }
            }
            .prayerCard()
        }
    }

    private func rowState(for prayer: Prayer) -> PrayerRowState {
        if session.recordedPhase(for: prayer) == .checkedIn {
            return .complete
        }

        let entry = session.schedule?.entries.first { $0.prayer == prayer }
        if entry?.id == session.currentEventID && session.isPrayerTime {
            switch session.phase {
            case .checkedIn: return .complete
            case .unlocked: return .current("Unlocked")
            case .inProgress: return .current("In prayer")
            case .ready: return .current("It’s time")
            }
        }

        if let entry, entry.date <= Date() { return .upcoming("No check-in") }
        if session.schedule?.entries.first(where: { $0.date > Date() })?.prayer == prayer {
            return .upcoming("Coming next")
        }

        return .upcoming(prayer == .isha ? "Tonight" : "Later today")
    }
}

private enum PrayerRowState {
    case complete
    case current(String)
    case upcoming(String)
}

private struct PrayerRow: View {
    let prayer: Prayer
    let state: PrayerRowState
    let time: String?

    var body: some View {
        HStack(spacing: 14) {
            stateIcon
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(prayer.displayName)
                    .font(.body.weight(.medium))
                    .foregroundStyle(PrayerTheme.ink)
                if let time {
                    Text(time).font(.caption).foregroundStyle(PrayerTheme.secondaryInk)
                }
            }

            Spacer()

            Text(statusText)
                .font(.subheadline.weight(isCurrent ? .semibold : .regular))
                .foregroundStyle(isCurrent || isComplete ? PrayerTheme.sage : PrayerTheme.secondaryInk)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 58)
        .background(isCurrent ? PrayerTheme.sageSoft.opacity(0.72) : Color.clear)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var stateIcon: some View {
        if isComplete {
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(PrayerTheme.sage, in: Circle())
        } else {
            Circle()
                .stroke(isCurrent ? PrayerTheme.sage : PrayerTheme.secondaryInk.opacity(0.72), lineWidth: 1.5)
                .frame(width: 24, height: 24)
        }
    }

    private var statusText: String {
        switch state {
        case .complete: "Completed"
        case .current(let text), .upcoming(let text): text
        }
    }

    private var isComplete: Bool {
        if case .complete = state { return true }
        return false
    }

    private var isCurrent: Bool {
        if case .current = state { return true }
        return false
    }
}
