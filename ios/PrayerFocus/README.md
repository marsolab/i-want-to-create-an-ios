# Prayer Focus for iPhone

This folder contains the first native SwiftUI slice of the approved Prayer Focus experience.

## Included

- Arch-and-mosque Today screen without the rejected masthead or slogan block
- Local start, finish, already-prayed, and unlock-without-check-in states
- Five prayer rows with focus enabled for every prayer by default
- Setup before the paywall, with locally persisted per-prayer settings, app selection, placeholder schedule choices, notification preferences and setup completion
- Family Controls individual-authorization request and Apple's `FamilyActivityPicker`
- Unit tests for the local prayer focus state machine
- Native UI tests for setup ordering and persistence, trial/plan disclosure, blocked swipe dismissal, Privacy and access after a verified trial
- Selected mosque-led membership paywall, annual/monthly selection and matching renewal disclosure
- Blurred image behind the membership sheet and status bar, with a soft ivory fade from the paywall photo into its content
- StoreKit purchase, restore and verified-entitlement gate; the paywall slides up in a large native sheet with no close control or interactive dismissal until an active subscription is verified
- 30 original English daily affirmations, a Settings guide, and small/medium Home Screen plus rectangular Lock Screen widgets
- Calendar-day/DST/time-zone selection, expiration-aware widget timelines, and a pending widget destination that waits for membership verification

## Membership design

The October 4 direction is setup → membership → three days free → monthly or yearly billing. The user configures the app before seeing the paywall; those choices persist through relaunches and cancelled purchases. Completing setup does not start a trial or grant product access. A verified StoreKit trial or subscription unlocks the Today flow.

Both plans offer a three-day introductory free trial to eligible Apple Accounts. Yearly is selected by default and displays the full $35.88/year, with $2.99/month as an optional secondary equivalent when StoreKit's price metadata agree. Monthly is $3.99/month. The action reads “Start 3-day free trial”; the disclosure states “3 days free, then [full price]/[year or month].” The app checks the actual introductory-offer metadata and StoreKit eligibility. Accounts that have already used the group's offer see “Subscribe” and ordinary billing. Unsupported eligible introductory offers are blocked rather than described with incorrect terms.

These are local preview/test prices. Configure supported actual App Store prices before release. StoreKit's localized prices replace them when products are available. Show the annual monthly equivalent only when StoreKit's numeric and display prices agree; some local testing runtimes return truncated numeric prices. The full yearly charge remains visible in all cases.

The subscription identifiers are `com.marsolab.PrayerFocus.yearly` and `com.marsolab.PrayerFocus.monthly`. In App Store Connect:

1. Put both auto-renewable products in the same subscription group, with durations of one year and one month.
2. Add a **Free, 3 Days** introductory offer to each product for the intended storefronts and dates.
3. Confirm product prices and availability, then test new-account trial purchase, trial renewal into paid membership, cancellation, ineligible accounts, restoration, pending purchases and expiration in the sandbox.

Apple permits one introductory offer per account per subscription group; changing plans does not provide another trial. See [Apple's introductory-offer configuration guide](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-introductory-offers-for-auto-renewable-subscriptions/).

`Configuration/PrayerFocus.storekit` supplies both offers to local Xcode runs and tests, without changing App Store Connect. It is bundled only into test targets. Until live products exist, Subscribe reports unavailability and never grants access. Successful production billing still requires App Store Connect configuration and StoreKit sandbox/device validation. The local Privacy sheet is informational; provide a published privacy-policy URL before release.

The existing Today flow can be opened in Debug builds with the `-preview-today` launch argument. This design-preview switch is excluded from Release builds.

## Daily affirmation widgets

Open Settings → Daily affirmations for today's reflection, sample widget sizes, and installation instructions. The widgets show one original reflection per local Gregorian day and repeat the bundled collection after 30 days. Widget taps use `prayerfocus://daily-affirmation`. Requests made while the app checks access or presents the paywall are retained until a verified subscription is available.

The app and `PrayerFocusWidgets` extension both declare App Group `group.com.marsolab.PrayerFocus`. In the Apple Developer account, register this group and enable it for both `com.marsolab.PrayerFocus` and `com.marsolab.PrayerFocus.Widgets`; use the same development team and matching provisioning profiles. Both targets' version/build values come from `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`.

The app publishes recognized product ID, expiration, and verification date from verified active StoreKit entitlements. Missing, unreadable, malformed, or expired data shows “Open Prayer Focus to continue.” A locked entry is scheduled at subscription expiration. Revocation is detected when the app next refreshes StoreKit access; while offline or without reopening the app, the widget can only use its last verified snapshot until that snapshot expires. WidgetKit controls refresh timing, so daily changes are scheduled without promising an exact midnight redraw.

Debug-only `-preview-affirmation` displays the guide using the longest reflection. `-open-affirmation` exercises a pending widget destination behind the normal membership gate. Neither argument grants or writes widget membership; both are excluded from Release builds.

See [widget QA](affirmation-widgets-qa.md) for verification evidence and remaining physical-device/StoreKit checks.

## Build

Current setup/trial validation and screenshots: [setup and trial QA](setup-trial-qa.md).

```sh
cd ios/PrayerFocus
xcrun swift-format lint --strict --recursive --configuration .swift-format \
  PrayerFocusApp Shared PrayerFocusWidgets PrayerFocusTests PrayerFocusUITests
xcodegen generate
xcodebuild \
  -project PrayerFocus.xcodeproj \
  -scheme PrayerFocus \
  -testPlan PrayerFocusWidgets \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -parallel-testing-enabled NO \
  test
```

`PrayerFocusWidgets` is the default test plan for calendar, access policy, refresh coordination, navigation, and widget checks. `PrayerFocus` covers setup, trial eligibility, purchases, renewal, restoration, and paywall UI with the three-day fixture. Select it with `-testPlan PrayerFocus`. `PrayerFocusStoreKit` retains the widget entitlement and deep-link integration cases with the no-trial fixture; select it with `-testPlan PrayerFocusStoreKit`. Run the StoreKit plans sequentially on a runtime with a working local StoreKit testing service. Both fixtures are included only in test targets, and neither is bundled into the release app or widget. The Xcode Run action uses `Configuration/PrayerFocus.storekit` for the current trial flow.

## Current platform gate

The simulator build does not claim to shield apps. Scheduled shielding still needs the Family Controls distribution entitlement, Managed Settings and Device Activity extension targets, and validation on a physical iPhone. The settings UI says this directly.
