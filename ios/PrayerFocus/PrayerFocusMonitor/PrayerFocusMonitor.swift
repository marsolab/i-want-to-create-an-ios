import DeviceActivity

final class PrayerFocusMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        FocusRuntime().handleBoundary()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        FocusRuntime().handleBoundary()
    }
}
