import Adhan
import Foundation

struct PrayerLocation: Sendable {
    let name: String
    let latitude: Double
    let longitude: Double
    let timeZoneID: String

    static let supported: [PrayerLocation] = [
        .init(name: "London", latitude: 51.5074, longitude: -0.1278, timeZoneID: "Europe/London"),
        .init(name: "New York", latitude: 40.7128, longitude: -74.0060, timeZoneID: "America/New_York"),
        .init(name: "Toronto", latitude: 43.6532, longitude: -79.3832, timeZoneID: "America/Toronto"),
        .init(name: "Dubai", latitude: 25.2048, longitude: 55.2708, timeZoneID: "Asia/Dubai"),
        .init(name: "Kuala Lumpur", latitude: 3.1390, longitude: 101.6869, timeZoneID: "Asia/Kuala_Lumpur"),
    ]
}

struct PrayerScheduleEntry: Identifiable, Equatable, Sendable {
    let prayer: Prayer
    let date: Date
    let dayKey: String
    var id: String { "\(dayKey).\(prayer.rawValue)" }
}

struct PrayerSchedule: Sendable {
    let entries: [PrayerScheduleEntry]
    let timeZoneID: String

    func current(at date: Date) -> PrayerScheduleEntry? {
        entries.last { $0.date <= date }
    }

    func time(for prayer: Prayer) -> String? {
        guard let entry = entries.first(where: { $0.prayer == prayer }),
            let zone = TimeZone(identifier: timeZoneID)
        else { return nil }
        return formattedTime(entry.date, in: zone)
    }

    func formattedTime(_ date: Date) -> String? {
        guard let zone = TimeZone(identifier: timeZoneID) else { return nil }
        return formattedTime(date, in: zone)
    }

    private func formattedTime(_ date: Date, in zone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = zone
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum PrayerScheduleCalculator {
    static func calculate(
        city: String, method: String, hanafiAsr: Bool = false, highLatitudeRule: String = "Recommended for city",
        adjustments: [String: Int] = [:],
        on date: Date = Date()
    ) -> PrayerSchedule? {
        guard date.timeIntervalSince1970.isFinite,
            let location = PrayerLocation.supported.first(where: { $0.name == city }),
            let zone = TimeZone(identifier: location.timeZoneID),
            let selectedMethod = calculationMethod(named: method)
        else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let coordinates = Coordinates(latitude: location.latitude, longitude: location.longitude)
        var parameters = selectedMethod.params
        parameters.madhab = hanafiAsr ? .hanafi : .shafi
        switch highLatitudeRule {
        case "Recommended for city": parameters.highLatitudeRule = HighLatitudeRule.recommended(for: coordinates)
        case "Middle of night": parameters.highLatitudeRule = .middleOfTheNight
        case "Seventh of night": parameters.highLatitudeRule = .seventhOfTheNight
        case "Twilight angle": parameters.highLatitudeRule = .twilightAngle
        default: return nil
        }
        let offsets = Prayer.allCases.map { min(120, max(-120, adjustments[$0.rawValue, default: 0])) }
        parameters.adjustments = PrayerAdjustments(
            fajr: offsets[0], dhuhr: offsets[1], asr: offsets[2], maghrib: offsets[3], isha: offsets[4])
        guard let times = PrayerTimes(coordinates: coordinates, date: components, calculationParameters: parameters)
        else { return nil }
        let dates = [times.fajr, times.dhuhr, times.asr, times.maghrib, times.isha]
        // Reject invalid or overlapping schedules instead of displaying misleading times.
        guard dates.allSatisfy({ $0.timeIntervalSince1970.isFinite }),
            zip(dates, dates.dropFirst()).allSatisfy({ $0 < $1 })
        else { return nil }
        let dayKey = String(format: "%04d-%02d-%02d", components.year!, components.month!, components.day!)
        return PrayerSchedule(
            entries: zip(Prayer.allCases, dates).map {
                PrayerScheduleEntry(prayer: $0, date: $1, dayKey: dayKey)
            }, timeZoneID: location.timeZoneID)
    }

    private static func calculationMethod(named name: String) -> CalculationMethod? {
        switch name {
        case "Muslim World League": .muslimWorldLeague
        case "ISNA": .northAmerica
        case "Umm al-Qura": .ummAlQura
        case "Egyptian Authority": .egyptian
        case "Dubai": .dubai
        case "Moonsighting Committee": .moonsightingCommittee
        case "Singapore": .singapore
        default: nil
        }
    }
}
