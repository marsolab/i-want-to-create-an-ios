# Muslim iOS app — product and launch documents

Updated October 3, 2026. Product direction: a calm, voluntary iPhone Prayer Focus with paid membership and a focus flow for user-selected distracting apps at prayer time.

| Document | Current status |
|---|---|
| [Product requirements](PRD.md) | Current beta scope, daily flow, privacy, Screen Time feasibility gate, acceptance criteria and validation |
| [`ios/PrayerFocus/`](../ios/PrayerFocus/) | Buildable SwiftUI slice with local focus state and Family Controls picker boundary |
| [App names](app-names.md) | Earlier naming exploration; no app name has been selected |
| [Marketing strategy](marketing-strategy.md) | Earlier launch hypothesis; revisit after the Prayer Focus beta and recruitment cohort are chosen |
| [Earlier market research](muslim-ios-app-market-opportunity.md) | Background research, superseded where the current PRD narrows product scope |

## Current product decisions

- **First market:** English-speaking Muslims worldwide. Arabic comes next, followed by Persian and other languages.
- **Core value:** with the user's permission, shield selected apps at the start of enabled prayers. By default focus is enabled for all five daily prayers and can be changed per prayer.
- **User control:** start/finish check-ins, “Already prayed,” an explicit per-prayer unlock without a completion record, and a pause. Missing check-ins do not accumulate restrictions.
- **Membership:** fully paid, with no free tier or trial. Annual displays $2.99/month with the $35.88 yearly charge below Subscribe; monthly displays $3.99/month. Actual StoreKit pricing and sandbox purchases require configuration and validation before release.
- **Beta boundaries:** iPhone, English, local storage, no account. Qibla, lessons, journal, widget, analytics and cloud sync are deferred.
- **Visual direction:** warm white, muted sand and sage, generous space, legible type, and the approved arch-and-mosque hero. The rejected top masthead and slogan block are omitted.

The native slice compiles and exercises the self-reported prayer flow, but scheduled app shielding is not yet validated. Apple approval for Family Controls distribution, a physical-device technical spike, supported prayer-time conventions, a qualified reviewer, app name, and accessible English-speaking beta participants remain open gates.
