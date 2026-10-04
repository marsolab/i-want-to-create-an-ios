# Daily Affirmation Widgets Implementation Plan

> **For agentic workers:** Use executing-plans to implement this plan task-by-task in this session. Steps use checkboxes for tracking.

**Goal:** Add three daily affirmation widget families and a membership-gated destination to Prayer Focus.

**Architecture:** A shared, deterministic local catalog and membership snapshot policy serve the app and WidgetKit extension. The app writes verified StoreKit product/expiration data into its App Group and requests reloads; the extension builds dated entries, including a locked entry at expiration. A pending URL destination survives the existing membership gate.

**Tech Stack:** Swift 6, SwiftUI, Foundation, StoreKit 2, WidgetKit, XCTest, XcodeGen, iOS 18+.

## Global constraints

- Use the approved 30 English original reflections, labeled as original content in the app.
- Keep warm ivory, sage, and sand Home Screen styling, with readable system monochrome/tinted rendering.
- Support `systemSmall`, `systemMedium`, and `accessoryRectangular`; keep the prayer journey primary.
- One text per local Gregorian calendar day, with a 30-day cycle anchored to January 1, 2026.
- Seven future local midnights, plus membership expiration; no exact system refresh guarantee.
- Missing/malformed/expired/revoked shared access is locked. No free tier or trial.
- No accounts, remote generation, notifications, favorites, theme picker, or new dependencies.
- Report simulator evidence separately from physical-device and StoreKit sandbox verification.

## Task 1: Shared catalog, access policy, and timeline

**Create:**
- `ios/PrayerFocus/Shared/Affirmations/DailyAffirmation.swift`: immutable 30-item catalog, Gregorian day arithmetic.
- `ios/PrayerFocus/Shared/Affirmations/WidgetMembership.swift`: recognized subscription IDs, encoded snapshot, App Group store.
- `ios/PrayerFocus/Shared/Affirmations/AffirmationTimeline.swift`: dated content/locked entries and sorted expiration insertion.
- `ios/PrayerFocus/PrayerFocusTests/DailyAffirmationTests.swift`: date and catalog invariants.
- `ios/PrayerFocus/PrayerFocusTests/AffirmationTimelineTests.swift`: expired, malformed, missing, revoked, and valid snapshot behavior.

**Modify:** `ios/PrayerFocus/project.yml` to add `Shared` to the app's sources.

**Interfaces:**
```swift
struct DailyAffirmation: Identifiable, Equatable, Sendable {
    let id: Int
    let theme: String
    let text: String
}
// Catalog exposes all, calendar(timeZone:), and affirmation(on:timeZone:).
// WidgetMembershipSnapshot exposes productID, expirationDate, verifiedAt,
// and allowsAccess(at:). Store exposes read() and write(_:).
// AffirmationTimeline.entries(from:timeZone:membership:) returns sorted
// AffirmationEntry(date:affirmation:), with nil affirmation when locked.
```

- [ ] Write tests that assert same-day selection, a 30-day wrap, negative-day modulo, leap day, New York DST calendar spacing, and different local dates in Dubai/Los Angeles.
- [ ] Run the new unit tests before shared types exist; confirm compilation fails for the missing symbols.
- [ ] Implement the immutable approved corpus, day selection, strict snapshot validation, and timeline policy. Membership is valid only for a recognized product, finite timestamps, `verifiedAt <= now < expirationDate`, and a nonzero validity interval.
- [ ] Persist encoded snapshots with injected `UserDefaults` for tests and an entitled App Group suite in production. A nil snapshot removes the saved data.
- [ ] Test corrupted JSON and explicit removal. Test an expiration in the middle of a day and at midnight: every entry at or after expiration is locked and duplicate boundary dates are removed.
- [ ] Run all app unit tests. Expected: existing prayer tests and the new policy tests pass.

Commands, from `ios/PrayerFocus`:
```sh
xcodegen generate
xcodebuild -project PrayerFocus.xcodeproj -scheme PrayerFocus \
  -destination 'platform=iOS Simulator,id=4FA8BD04-2F42-453B-A753-C6254E949C9C' \
  -only-testing:PrayerFocusTests -parallel-testing-enabled NO test
```

## Task 2: Embedded extension and StoreKit publication

**Create:**
- `ios/PrayerFocus/PrayerFocusWidgets/DailyAffirmationWidget.swift`: provider, widget, gallery previews.
- `ios/PrayerFocus/Shared/Affirmations/AffirmationWidgetCard.swift`: layouts shared with the in-app widget guide.
- `ios/PrayerFocus/PrayerFocusApp/PrayerFocus.entitlements` and `ios/PrayerFocus/PrayerFocusWidgets/PrayerFocusWidgets.entitlements`: `group.com.marsolab.PrayerFocus`.

**Modify:** `project.yml`, generated `PrayerFocus.xcodeproj`, `MembershipStore.swift`.

**Interfaces:**
```swift
// AffirmationEntry conforms to TimelineEntry in the widget target.
// DailyAffirmationProvider reads WidgetMembershipStore and constructs Timeline
// using AffirmationTimeline.entries; previews alone may show sample content.
// AffirmationWidgetCard(affirmation:family:) handles all three families.
// MembershipStore.refreshAccess publishes the longest verified active expiration.
```

- [ ] Add the extension target with the `com.apple.widgetkit-extension` extension point, matching version/deployment values, App Group entitlement, extension-safe shared sources, and embedded app dependency.
- [ ] Publish a snapshot after verified active StoreKit entitlement enumeration; clear it when none remain. Only reload when shared data changes; reload on app activation for local date/time-zone changes.
- [ ] Implement complete-text small and medium cards, with a crescent, title, theme, and restrained medium arch. Lock Screen omits secondary labels to preserve space.
- [ ] Use `containerBackground(for: .widget)` in the real widget, `.widgetURL` for its destination, and `.widgetRenderingMode`/`.widgetAccentable` for system appearances.
- [ ] Build app plus extension. Expected: no compiler errors or unsafe extension API warnings; the app contains `PrayerFocusWidgets.appex`.

## Task 3: App destination and widget guide

**Create:**
- `ios/PrayerFocus/PrayerFocusApp/Features/Affirmations/AffirmationDestination.swift`: accepted URL and pending destination state.
- `ios/PrayerFocus/PrayerFocusApp/Features/Affirmations/DailyAffirmationView.swift`: daily text, original-content label, previews and installation instructions.
- `ios/PrayerFocus/PrayerFocusTests/AffirmationDestinationTests.swift`: pending/checking/locked/access transitions and unknown URLs.
- `ios/PrayerFocus/PrayerFocusUITests/DailyAffirmationUITests.swift`: guide navigation and debug-only preview screenshots.

**Modify:** `PrayerFocusApp.swift`, `MembershipGateView.swift`, `FocusSettingsView.swift`, `PrayerHeroView.swift`.

**Interfaces:**
```swift
// AffirmationDestination stores a pending request and provides
// receive(_ url: URL), request(), and consumeIfAllowed(hasAccess:hasCheckedEntitlements:).
// The root sheet consumes only after checked and verified access.
// Settings uses NavigationLink to DailyAffirmationView.
```

- [ ] Register `prayerfocus` URL scheme, and accept only `prayerfocus://daily-affirmation` with no unexpected path or query.
- [ ] Preserve the request across access checking/paywall. Show the daily view only after the paywall dismisses; dismiss it if access expires.
- [ ] Add Settings navigation and a standalone dismissal toolbar for the root destination. Use `TimelineView` plus calendar boundaries so a foreground view advances with the day.
- [ ] Add a Debug-only `-preview-affirmation` visual route. It never writes membership data and is absent from Release code.
- [ ] UI-test the Settings route with the existing Today debug preview, capture all three preview families, and verify URL access stays behind the paywall without a subscription.
- [ ] Run existing membership UI tests and new UI tests. Expected: prayer UI and locked paywall behavior remain valid.

## Task 4: Delivery checks and documentation

**Modify:** `docs/README.md`, `docs/PRD.md`, `ios/PrayerFocus/README.md`, this plan.
**Create:** `ios/PrayerFocus/affirmation-widgets-qa.md` and visual evidence under `qa-evidence/`.

- [ ] Replace stale deferred-widget scope statements with the approved three-family feature.
- [ ] Document shared App Group signing setup, offline revocation limitation, widget installation, and outstanding device/sandbox checks.
- [ ] Format and lint all Swift sources; generate the final Xcode project.
- [ ] Run all unit and UI tests once the final code is stable, and build Release to ensure Debug preview access is excluded.
- [ ] Inspect saved preview screenshots for full longest-text rendering, all three families, locked state, and tinted/monochrome presentation.
- [ ] Review final diff for unintended changes, run `git diff --check`, and commit this feature on `codex/daily-affirmation-widgets`. Do not push or merge without a separate request.

Final formatting:
```sh
xcrun swift-format format --in-place --recursive --configuration .swift-format \
  PrayerFocusApp Shared PrayerFocusWidgets PrayerFocusTests PrayerFocusUITests
xcrun swift-format lint --strict --recursive --configuration .swift-format \
  PrayerFocusApp Shared PrayerFocusWidgets PrayerFocusTests PrayerFocusUITests
```
