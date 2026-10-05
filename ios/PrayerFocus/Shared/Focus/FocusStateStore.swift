import Darwin
import Foundation

struct FocusStateStore: Sendable {
    let directory: URL?

    init(
        directory: URL? = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: WidgetMembershipStore.appGroupID)
    ) {
        self.directory = directory
    }

    @discardableResult
    func transaction(_ action: (inout SharedFocusState?) throws -> Void) -> Bool {
        guard let directory else { return false }
        let lockURL = directory.appendingPathComponent("focus-state.lock")
        let descriptor = open(lockURL.path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { return false }
        defer { close(descriptor) }
        guard flock(descriptor, LOCK_EX) == 0 else { return false }
        defer { flock(descriptor, LOCK_UN) }
        let url = directory.appendingPathComponent("focus-state-v1.json")
        do {
            var state = (try? Data(contentsOf: url)).flatMap {
                try? JSONDecoder().decode(SharedFocusState.self, from: $0)
            }
            try action(&state)
            if let state {
                try JSONEncoder().encode(state).write(to: url, options: .atomic)
            } else if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            return true
        } catch {
            return false
        }
    }
}
