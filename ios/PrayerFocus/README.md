# Prayer Focus for iPhone

This folder contains the first native SwiftUI slice of the approved Prayer Focus experience.

## Included

- Arch-and-mosque Today screen without the rejected masthead or slogan block
- Local start, finish, already-prayed, and unlock-without-check-in states
- Five prayer rows with focus enabled for every prayer by default
- Per-prayer settings, placeholder schedule choices, and notification preference UI
- Family Controls individual-authorization request and Apple's `FamilyActivityPicker`
- Unit tests for the local prayer focus state machine
- Native UI tests for plan selection, renewal disclosure, blocked swipe dismissal and the Privacy sheet
- Selected mosque-led membership paywall, annual/monthly selection and matching renewal disclosure
- Blurred image behind the membership sheet and status bar, with a soft ivory fade from the paywall photo into its content
- StoreKit purchase, restore and verified-entitlement gate; the paywall slides up in a large native sheet with no close control or interactive dismissal until an active subscription is verified
- 30 original English daily affirmations, a Settings guide, and small/medium Home Screen plus rectangular Lock Screen widgets
- Calendar-day/DST/time-zone selection, expiration-aware widget timelines, and a pending widget destination that waits for membership verification

## Membership design

The October 3 direction is fully paid, with no free tier or free trial. The annual offer displays $2.99/month, billed as $35.88/year. Monthly is $3.99/month. The annual plan is selected by default; its actual full charge appears in the renewal disclosure below Subscribe. These are design-preview amounts: configure the actual supported App Store pricing before release. StoreKit's localized product prices replace the preview when products are available; the annual monthly equivalent is calculated from the loaded price divided by twelve.

The subscription identifiers are `com.marsolab.PrayerFocus.yearly` and `com.marsolab.PrayerFocus.monthly`. Configure them as one-year and one-month auto-renewable subscriptions in the same App Store Connect group, with no introductory trial. Until they exist, Subscribe displays an unavailable message and never grants access. Successful billing, restoration and expiration still require StoreKit sandbox/device validation. The local Privacy sheet is informational; provide a published privacy-policy URL before release.

The existing Today flow can be opened in Debug builds with the `-preview-today` launch argument. This design-preview switch is excluded from Release builds.

## Daily affirmation widgets

Open Settings → Daily affirmations for today's reflection, sample widget sizes, and installation instructions. The widgets show one original reflection per local Gregorian day and repeat the bundled collection after 30 days. Widget taps use `prayerfocus://daily-affirmation`. Requests made while the app checks access or presents the paywall are retained until a verified subscription is available.

The app and `PrayerFocusWidgets` extension both declare App Group `group.com.marsolab.PrayerFocus`. In the Apple Developer account, register this group and enable it for both `com.marsolab.PrayerFocus` and `com.marsolab.PrayerFocus.Widgets`; use the same development team and matching provisioning profiles. Both targets' version/build values come from `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`.

The app publishes recognized product ID, expiration, and verification date from verified active StoreKit entitlements. Missing, unreadable, malformed, or expired data shows “Open Prayer Focus to continue.” A locked entry is scheduled at subscription expiration. Revocation is detected when the app next refreshes StoreKit access; while offline or without reopening the app, the widget can only use its last verified snapshot until that snapshot expires. WidgetKit controls refresh timing, so daily changes are scheduled without promising an exact midnight redraw.

Debug-only `-preview-affirmation` displays the guide using the longest reflection. `-open-affirmation` exercises a pending widget destination behind the normal membership gate. Neither argument grants or writes widget membership; both are excluded from Release builds.

See [widget QA](affirmation-widgets-qa.md) for verification evidence and remaining physical-device/StoreKit checks.

## Build

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

`PrayerFocusWidgets` is the default test plan for calendar, access policy, refresh coordination, navigation, and paywall checks. Real local StoreKit integration cases are retained in the separate `PrayerFocusStoreKit` plan. Select that plan with `-testPlan PrayerFocusStoreKit` on a runtime with a working local StoreKit testing service. The no-trial `Configuration/PrayerFocusWidgetsTesting.storekit` fixture is included only in test targets and the Xcode run/test configuration; it is not bundled into the release app or widget.

## Current platform gate

The simulator build does not claim to shield apps. Scheduled shielding still needs the Family Controls distribution entitlement, Managed Settings and Device Activity extension targets, and validation on a physical iPhone. The settings UI says this directly.
