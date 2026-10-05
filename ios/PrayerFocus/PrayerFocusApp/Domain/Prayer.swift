import Foundation

enum Prayer: String, CaseIterable, Codable, Identifiable, Sendable {
    case fajr
    case dhuhr
    case asr
    case maghrib
    case isha

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fajr: "Fajr"
        case .dhuhr: "Dhuhr"
        case .asr: "Asr"
        case .maghrib: "Maghrib"
        case .isha: "Isha"
        }
    }
}

enum PrayerSessionPhase: String, Codable, Equatable, Sendable {
    case ready
    case inProgress
    case checkedIn
    case unlocked
}
