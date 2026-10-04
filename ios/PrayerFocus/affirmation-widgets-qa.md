# Daily affirmation widget QA

Date: October 4, 2026.

## Scope and evidence

Implemented 30 original English reflections, small and medium Home Screen widgets, a rectangular Lock Screen widget, Settings guide, and a membership-gated URL destination. The app and extension embed the same local catalog and calendar policy.

Environment: Xcode 27.0 (27A266a), iPhone 17 Pro simulator running iOS 26.5. A dedicated simulator named “Prayer Focus Widget QA” was created for these checks. No physical-device or App Store Connect changes were made.

Final local verification:

- The `PrayerFocusWidgets` test plan passed all **30 tests: 23 unit and 7 UI**, with zero failures and zero skipped cases within that plan. Result: `/tmp/prayerfocus-affirmations-final-4.xcresult`; log: `/tmp/prayerfocus-affirmations-final-4.log`.
- Unit coverage includes the 30-item catalog, cycle/date/time-zone/DST boundaries, strict snapshot storage and validation, expiration entries beyond the content horizon, pending destinations, overlapping entitlement refresh callers, and app/shared-state expiration without another StoreKit request.
- UI coverage includes the existing membership offer/privacy behavior, the Settings guide, complete longest-text previews in all three families, a locked pending URL, native gallery installation of a small widget, and its warm tap returning to the membership paywall. The installed widget showed the locked copy and did not expose daily content.
- Visual inspection confirmed complete text in the small and medium previews and the monochrome Lock Screen preview. The system gallery and installed locked small widget were also inspected. These are simulator captures, not physical-device evidence.
- Swift formatting/lint, final XcodeGen generation, and `git diff --check` passed.
- The final Release simulator build passed in `/tmp/prayerfocus-affirmations-release.log`. Its app embeds `PrayerFocusWidgets.appex`; both carry version `0.1.0`, build `1`, and the same declared App Group. The registered URL scheme is present. All three Debug launch argument strings and all `.storekit` fixtures are absent from the release app bundle. This verifies simulator products, not device provisioning.

Images:

- [Daily reflection and small preview](qa-evidence/affirmation-widgets/daily-and-small.png)
- [Medium and Lock Screen previews](qa-evidence/affirmation-widgets/medium-and-lock-screen.png)
- [Native iOS widget gallery](qa-evidence/affirmation-widgets/native-widget-gallery.png)
- [Installed locked Home Screen widget](qa-evidence/affirmation-widgets/installed-home-screen.png)

## Access behavior

The production app enumerates cryptographically verified StoreKit current entitlements. It publishes recognized product ID, expiration date, and verification date into `group.com.marsolab.PrayerFocus`. App access checks the expiration date rather than a cached unlimited boolean. A foreground expiration task clears app and shared widget access.

Every active widget timeline includes the recorded subscription expiration, including expiration dates beyond the seven-day content horizon. A separate seven-day reload request replenishes daily content. A delayed system reload may leave the previous reflection visible, but the already-scheduled expiration entry remains present.

URLs wait for the current entitlement refresh. All refresh callers await a coalesced operation; a request arriving during enumeration causes a fresh pass before publication. Settings closes before the pending widget destination is consumed. Expiration closes member content before presenting the paywall.

The widget detects revocation on the next app entitlement refresh. Offline or without reopening the app, it has only its last verified snapshot and recorded expiration. This limitation is preserved explicitly.

## StoreKit integration remains unverified

Local StoreKit tests were attempted with `Configuration/PrayerFocusWidgetsTesting.storekit` bundled into test targets and referenced by an Xcode test plan. The installed iOS 26.5 `storekitd` rejected saving the configuration and changing its settings with `SKInternalErrorDomain Code=3`; purchases returned `notEntitled` or `InvalidTransition`. These errors occur at the local testing service boundary before the app can receive a successful verified purchase.

The ordinary `PrayerFocusWidgets` test plan excludes the two `AffirmationMembershipTests` and three `AffirmationMembershipUITests` integration cases. They remain runnable in `PrayerFocusStoreKit` with the explicit configuration, without weakening production verification:

```sh
xcodebuild -project PrayerFocus.xcodeproj -scheme PrayerFocus \
  -testPlan PrayerFocusStoreKit \
  -destination 'platform=iOS Simulator,name=Prayer Focus Widget QA' \
  -parallel-testing-enabled NO test
```

The local testing limitation is consistent with the [iOS 26.5 release note discussing StoreKit configuration saving](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-26_5-release-notes) and an [Apple Developer Forums report of the same CLI symptom](https://developer.apple.com/forums/thread/826971). The forum report is corroborating context, not proof of this machine's root cause; the local test logs provide the observed failure.

## Remaining release checks

- Enable the App Group for the signed app and extension IDs under the same Apple development team and confirm positive shared access on a physical iPhone.
- Validate live/sandbox purchase, restore, transaction revocation, expiration, and widget reloads with configured App Store products. Local test fixtures do not establish Apple sandbox or production billing.
- On a physical iPhone, add all three widget families, check a local-day rollover and time-zone change, and check tinted presentation, VoiceOver, larger text, and Lock Screen readability.
- Run the retained StoreKit integration cases in a working local StoreKit environment; exercise purchase → pending destination, active URL while Settings is presented, and warm URL after expiration.
- Existing scheduled Screen Time shielding release gates still apply separately.
