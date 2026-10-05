import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

struct FocusRuntime {
    private let stateStore = FocusStateStore()
    private let managedSettings = ManagedSettingsStore(named: .init("salahside.focus"))
    private let center = DeviceActivityCenter()
    private let prefix = "salahside.focus."

    @discardableResult
    func configure(
        _ configuration: FocusScheduleConfiguration, selection: FamilyActivitySelection,
        releasedEventIDs: Set<String> = []
    ) -> Bool {
        let now = Date()
        let success = stateStore.transaction { state in
            let windows = FocusPolicy.windows(
                configuration: configuration, membership: WidgetMembershipStore().read(), at: now)
            let data = try JSONEncoder().encode(selection)
            let released = (state?.releasedEventIDs ?? []).union(releasedEventIDs)
            let pause = state?.pauseUntil
            state = SharedFocusState(
                configuration: configuration, selection: data, windows: windows,
                generatedAt: now, validUntil: windows.last?.end ?? now,
                releasedEventIDs: released.intersection(Set(windows.map(\.id))), pauseUntil: pause)
            try register(state!)
            apply(state, at: now)
        }
        if !success { stopAndClear() }
        return success
    }

    func handleBoundary() {
        let now = Date()
        let success = stateStore.transaction { state in
            guard var saved = state, saved.version == 1 else {
                stopAndClear()
                return
            }
            // Renew a bounded schedule from the saved manual city/settings. Membership
            // is checked again by the extension; stale or expired data always clears.
            saved.windows = FocusPolicy.windows(
                configuration: saved.configuration,
                membership: WidgetMembershipStore().read(), at: now)
            saved.generatedAt = now
            saved.validUntil = saved.windows.last?.end ?? now
            saved.releasedEventIDs.formIntersection(Set(saved.windows.map(\.id)))
            state = saved
            try register(saved)
            apply(saved, at: now)
        }
        if !success { stopAndClear() }
    }

    func applyCurrent() {
        if !stateStore.transaction({ apply($0, at: Date()) }) { managedSettings.clearAllSettings() }
    }

    func release(eventID: String) {
        let success = stateStore.transaction { state in
            state?.releasedEventIDs.insert(eventID)
            apply(state, at: Date())
        }
        if !success { managedSettings.clearAllSettings() }
    }

    func pause(until date: Date?) {
        let success = stateStore.transaction { state in
            state?.pauseUntil = date
            if let state { try register(state) }
            apply(state, at: Date())
        }
        if !success { stopAndClear() }
    }

    func erase() {
        stateStore.transaction {
            $0 = nil
            stopAndClear()
        }
        stopAndClear()
    }

    private func apply(_ state: SharedFocusState?, at now: Date) {
        let authorized = isAuthorized
        guard
            FocusPolicy.activeWindow(
                state: state, membership: WidgetMembershipStore().read(),
                authorized: authorized, at: now) != nil,
            let data = state?.selection,
            let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            managedSettings.clearAllSettings()
            return
        }
        let ownTokens = Set([Application(bundleIdentifier: "com.marsolab.PrayerFocus").token].compactMap { $0 })
        let applications = selection.applicationTokens.subtracting(ownTokens)
        managedSettings.shield.applications = applications.isEmpty ? nil : applications
        managedSettings.shield.applicationCategories =
            selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens, except: ownTokens)
        managedSettings.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        managedSettings.shield.webDomainCategories =
            selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
    }

    private var isAuthorized: Bool {
        let status = AuthorizationCenter.shared.authorizationStatus
        if #available(iOS 26.4, *), status == .approvedWithDataAccess { return true }
        return status == .approved
    }

    private func register(_ state: SharedFocusState) throws {
        let now = Date()
        guard isAuthorized, WidgetMembershipStore().read()?.allowsAccess(at: now) == true,
            let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: state.selection),
            !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
                || !selection.webDomainTokens.isEmpty
        else {
            stopAndClear()
            return
        }
        let windows = state.windows.filter { $0.end > now }
        var wanted = Set(windows.map { DeviceActivityName(prefix + $0.id) })
        let pauseName = DeviceActivityName(prefix + "pause")
        if let pause = state.pauseUntil, pause > now { wanted.insert(pauseName) }
        let existing = Set(center.activities.filter { $0.rawValue.hasPrefix(prefix) })
        center.stopMonitoring(Array(existing.subtracting(wanted)))
        for window in windows {
            let name = DeviceActivityName(prefix + window.id)
            let desired = schedule(start: window.start, end: window.end)
            // Retain an unchanged current monitor when the app opens. Restarting it
            // can redeliver boundaries, or lose its remaining interval.
            if center.schedule(for: name) != desired { try center.startMonitoring(name, during: desired) }
        }
        if let pause = state.pauseUntil, pause > now {
            // The only supported pause is one hour. Preserve its original full
            // interval even when reopening less than 15 minutes before expiry.
            let desired = schedule(start: pause.addingTimeInterval(-3600), end: pause)
            if center.schedule(for: pauseName) != desired { try center.startMonitoring(pauseName, during: desired) }
        }
    }

    private func schedule(start: Date, end: Date) -> DeviceActivitySchedule {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        func components(_ date: Date) -> DateComponents {
            var value = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            value.calendar = calendar
            value.timeZone = calendar.timeZone
            return value
        }
        return DeviceActivitySchedule(intervalStart: components(start), intervalEnd: components(end), repeats: false)
    }

    private func stopAndClear() {
        center.stopMonitoring(center.activities.filter { $0.rawValue.hasPrefix(prefix) })
        managedSettings.clearAllSettings()
    }
}
