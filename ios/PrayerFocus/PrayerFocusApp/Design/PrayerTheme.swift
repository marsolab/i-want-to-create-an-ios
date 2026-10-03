import SwiftUI

enum PrayerTheme {
    static let canvas = Color(red: 0.975, green: 0.965, blue: 0.942)
    static let surface = Color(red: 0.995, green: 0.992, blue: 0.981)
    static let sage = Color(red: 0.25, green: 0.42, blue: 0.33)
    static let sageDark = Color(red: 0.10, green: 0.24, blue: 0.20)
    static let sageSoft = Color(red: 0.91, green: 0.94, blue: 0.89)
    static let sand = Color(red: 0.78, green: 0.66, blue: 0.49)
    static let ink = Color(red: 0.07, green: 0.15, blue: 0.14)
    static let secondaryInk = Color(red: 0.34, green: 0.38, blue: 0.38)
    static let hairline = Color(red: 0.84, green: 0.83, blue: 0.79)

    static let pageMargin: CGFloat = 20
    static let cardRadius: CGFloat = 22
    static let controlHeight: CGFloat = 56
}

extension View {
    func prayerCard() -> some View {
        self
            .background(PrayerTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: PrayerTheme.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PrayerTheme.cardRadius, style: .continuous)
                    .stroke(PrayerTheme.hairline.opacity(0.72), lineWidth: 1)
            }
    }
}
