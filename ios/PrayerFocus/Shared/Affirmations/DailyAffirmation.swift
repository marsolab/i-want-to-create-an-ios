import Foundation

struct DailyAffirmation: Identifiable, Equatable, Sendable {
    let id: Int
    let theme: String
    let text: String
}

enum DailyAffirmationCatalog {
    static let all: [DailyAffirmation] = [
        .init(id: 0, theme: "Trust", text: "I take the next step with trust in Allah."),
        .init(id: 1, theme: "Intention", text: "I begin again with a sincere intention."),
        .init(id: 2, theme: "Gratitude", text: "I make room for gratitude in ordinary moments."),
        .init(id: 3, theme: "Patience", text: "I practice patience, one moment at a time."),
        .init(id: 4, theme: "Compassion", text: "I choose gentle words for myself and others."),
        .init(id: 5, theme: "Hope", text: "I turn to Allah with hope today."),
        .init(id: 6, theme: "Trust", text: "I do my part and entrust the outcome to Allah."),
        .init(id: 7, theme: "Intention", text: "I bring care and sincerity to my actions."),
        .init(id: 8, theme: "Gratitude", text: "I notice the blessings I often overlook."),
        .init(id: 9, theme: "Patience", text: "I give myself time to grow."),
        .init(id: 10, theme: "Compassion", text: "I can be kind while keeping healthy boundaries."),
        .init(id: 11, theme: "Hope", text: "I can return to what matters today."),
        .init(id: 12, theme: "Trust", text: "I ask Allah for guidance as I move forward."),
        .init(id: 13, theme: "Intention", text: "I make space for salah in my day."),
        .init(id: 14, theme: "Gratitude", text: "I can feel grateful and acknowledge what is hard."),
        .init(id: 15, theme: "Patience", text: "I meet this moment with a steady heart."),
        .init(id: 16, theme: "Compassion", text: "I offer kindness without needing recognition."),
        .init(id: 17, theme: "Hope", text: "I seek Allah's mercy with an open heart."),
        .init(id: 18, theme: "Trust", text: "I take a breath and place my trust in Allah."),
        .init(id: 19, theme: "Intention", text: "I choose one meaningful act of good today."),
        .init(id: 20, theme: "Gratitude", text: "I pause to appreciate what is here."),
        .init(id: 21, theme: "Patience", text: "I can pause before I respond."),
        .init(id: 22, theme: "Compassion", text: "I listen with care before I speak."),
        .init(id: 23, theme: "Hope", text: "I can begin again after a difficult day."),
        .init(id: 24, theme: "Trust", text: "I make du'a and take the steps within my reach."),
        .init(id: 25, theme: "Intention", text: "I give this prayer my attention."),
        .init(id: 26, theme: "Gratitude", text: "I express gratitude through my actions."),
        .init(id: 27, theme: "Patience", text: "I choose a small, steady step today."),
        .init(id: 28, theme: "Compassion", text: "I treat myself with the care I offer others."),
        .init(id: 29, theme: "Hope", text: "I turn toward Allah with a willing heart."),
    ]

    static func calendar(timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    static func affirmation(on date: Date, timeZone: TimeZone = .current) -> DailyAffirmation {
        let calendar = calendar(timeZone: timeZone)
        let anchor = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let days = calendar.dateComponents([.day], from: anchor, to: calendar.startOfDay(for: date)).day ?? 0
        let index = ((days % all.count) + all.count) % all.count
        return all[index]
    }
}
