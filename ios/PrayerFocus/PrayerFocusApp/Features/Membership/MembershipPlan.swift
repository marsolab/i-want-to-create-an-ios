import Foundation

enum MembershipPlan: String, CaseIterable, Identifiable {
    case yearly
    case monthly

    var id: String { rawValue }
    var title: String { self == .yearly ? "Yearly" : "Monthly" }
    var period: String { self == .yearly ? "year" : "month" }
    var billingPeriod: String { self == .yearly ? "yearly" : "monthly" }
    var previewPrice: String { self == .yearly ? "$35.88" : "$3.99" }
    var productID: String { "com.marsolab.PrayerFocus.\(rawValue)" }
}
