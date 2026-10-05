import Foundation

struct FocusScheduleConfiguration: Codable, Equatable, Sendable {
    let city: String
    let method: String
    let hanafiAsr: Bool
    var highLatitudeRule = "Recommended for city"
    let adjustments: [String: Int]
    let enabledPrayers: Set<String>
}

struct FocusWindow: Codable, Equatable, Sendable {
    let id: String
    let prayer: String
    let start: Date
    let end: Date
}

struct SharedFocusState: Codable {
    var version = 1
    var configuration: FocusScheduleConfiguration
    var selection: Data
    var windows: [FocusWindow]
    var generatedAt: Date
    var validUntil: Date
    var releasedEventIDs: Set<String> = []
    var pauseUntil: Date?
}
