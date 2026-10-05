import Foundation

enum FocusPolicy {
    static func activeWindow(
        state: SharedFocusState?, membership: WidgetMembershipSnapshot?, authorized: Bool, at now: Date
    ) -> FocusWindow? {
        guard authorized, let state, state.version == 1,
            now.timeIntervalSince1970.isFinite,
            state.generatedAt.timeIntervalSince1970.isFinite, state.validUntil.timeIntervalSince1970.isFinite,
            state.generatedAt <= now, now < state.validUntil,
            state.windows.count <= 20, Set(state.windows.map(\.id)).count == state.windows.count,
            state.windows.allSatisfy({
                $0.start.timeIntervalSince1970.isFinite && $0.end.timeIntervalSince1970.isFinite && $0.start < $0.end
            }),
            zip(state.windows, state.windows.dropFirst()).allSatisfy({ $0.end <= $1.start }),
            state.validUntil.timeIntervalSince(state.generatedAt) <= 4 * 86_400,
            membership?.allowsAccess(at: now) == true,
            state.pauseUntil.map({ $0 > now }) != true
        else { return nil }
        guard let window = state.windows.first(where: { $0.start <= now && now < $0.end }),
            window.end.timeIntervalSince(window.start) >= 15 * 60,
            window.end <= state.validUntil,
            window.end <= membership!.expirationDate,
            state.configuration.enabledPrayers.contains(window.prayer),
            !state.releasedEventIDs.contains(window.id)
        else { return nil }
        return window
    }

}
