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

## Membership design

The October 3 direction is fully paid, with no free tier or free trial. The annual offer displays $2.99/month, billed as $35.88/year. Monthly is $3.99/month. The annual plan is selected by default; its actual full charge appears in the renewal disclosure below Subscribe. These are design-preview amounts: configure the actual supported App Store pricing before release. StoreKit's localized product prices replace the preview when products are available; the annual monthly equivalent is calculated from the loaded price divided by twelve.

The subscription identifiers are `com.marsolab.PrayerFocus.yearly` and `com.marsolab.PrayerFocus.monthly`. Configure them as one-year and one-month auto-renewable subscriptions in the same App Store Connect group, with no introductory trial. Until they exist, Subscribe displays an unavailable message and never grants access. Successful billing, restoration and expiration still require StoreKit sandbox/device validation. The local Privacy sheet is informational; provide a published privacy-policy URL before release.

The existing Today flow can be opened in Debug builds with the `-preview-today` launch argument. This design-preview switch is excluded from Release builds.

## Build

```sh
cd ios/PrayerFocus
xcrun swift-format lint --strict --recursive --configuration .swift-format \
  PrayerFocusApp PrayerFocusTests PrayerFocusUITests
xcodegen generate
xcodebuild \
  -project PrayerFocus.xcodeproj \
  -scheme PrayerFocus \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  test
```

## Current platform gate

The simulator build does not claim to shield apps. Scheduled shielding still needs the Family Controls distribution entitlement, Managed Settings and Device Activity extension targets, and validation on a physical iPhone. The settings UI says this directly.
