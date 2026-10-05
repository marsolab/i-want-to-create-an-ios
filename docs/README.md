# Muslim iOS app — product and launch documents

Updated October 4, 2026. Product direction: a calm, voluntary iPhone Prayer Focus with setup before membership, a three-day trial, and daily affirmation widgets.

| Document | Current status |
|---|---|
| [Product requirements](PRD.md) | Current beta scope, daily flow, privacy, Screen Time feasibility gate, acceptance criteria and validation |
| [`ios/PrayerFocus/`](../ios/PrayerFocus/) | SwiftUI app with local focus state, Family Controls picker boundary, and a WidgetKit affirmation extension |
| [Daily affirmation widget design](superpowers/specs/2026-10-04-daily-affirmation-widgets-design.md) | Approved three-family scope and 30 original English reflections |
| [App names](app-names.md) | Earlier naming exploration; no app name has been selected |
| [Marketing strategy](marketing-strategy.md) | Earlier launch hypothesis; revisit after the Prayer Focus beta and recruitment cohort are chosen |
| [Earlier market research](muslim-ios-app-market-opportunity.md) | Background research, superseded where the current PRD narrows product scope |

## Current product decisions

- **First market:** English-speaking Muslims worldwide. Arabic comes next, followed by Persian and other languages.
- **Core value:** with the user's permission, shield selected apps at the start of enabled prayers. By default focus is enabled for all five daily prayers and can be changed per prayer.
- **User control:** start/finish check-ins, “Already prayed,” an explicit per-prayer unlock without a completion record, and a pause. Missing check-ins do not accumulate restrictions.
- **Membership flow:** configure the app first, then choose monthly or yearly membership. Eligible subscribers get a three-day free trial confirmed by Apple, followed by billing for the selected interval. Setup persists locally; product access requires an active verified trial or subscription.
- **Daily affirmations:** 30 original English reflections, with small/medium Home Screen widgets and a rectangular Lock Screen widget. One reflection per local day; membership applies to the app and installed widgets.
- **Beta boundaries:** iPhone, English, local storage, no account. Qibla, lessons, journal, analytics and cloud sync are deferred. Live billing requires configured App Store products and sandbox validation.
- **Visual direction:** warm white, muted sand and sage, generous space, legible type, and the approved arch-and-mosque hero. The rejected top masthead and slogan block are omitted.

The native slice compiles and exercises the self-reported prayer flow, but scheduled app shielding is not yet validated. Apple approval for Family Controls distribution, a physical-device technical spike, supported prayer-time conventions, a qualified reviewer, app name, and accessible English-speaking beta participants remain open gates.
