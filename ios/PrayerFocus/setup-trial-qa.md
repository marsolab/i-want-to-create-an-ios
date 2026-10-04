# Setup and three-day trial QA — October 4, 2026

Implemented the updated native flow: configure the app → membership → Apple-confirmed three-day trial → monthly or yearly auto-renewal. Setup completion, city, calculation method, notification preference, prayer switches and opaque Family Controls app selection persist locally. Cancelling a purchase preserves configuration and leaves membership locked. Review your setup remains available on the paywall.

## Verified locally

The final `xcodebuild test` completed successfully with **21 passed, 0 failed, 0 skipped** on iPhone 18 Pro, iOS 27, using the local StoreKit test plan. [Machine-readable summary](qa-evidence/setup-trial-2026-10-04/test-summary.json). Result bundle: `/tmp/prayer-focus-pr-validated.xcresult`; log: `/tmp/prayer-focus-pr-validated.log`.

- 3 setup tests: incomplete selections cannot advance; configuration survives relaunch; prayer switches and app-selection data persist and clear.
- 7 StoreKit tests: both products expose exactly three free days; a verified trial grants access; forced renewal produces a paid transaction of $3.99 for a month or $35.88 for a year; cancelled, pending and unavailable purchases grant no access; restore works; expiration removes access and prevents another introductory trial in the same group.
- 6 existing prayer-session tests continue to pass.
- 5 native UI tests: setup precedes membership and persists; disclosures follow the selected plan; swipe dismissal cannot bypass membership; Privacy opens and dismisses; an Apple-confirmed local trial opens Today.

Debug and Release simulator builds succeeded. The local `.storekit` fixture is included only in test bundles and is absent from the Release app. `git diff --check` and Swift source whitespace checks passed. No production payment or App Store Connect change was made.

The purchase tests observe and finish StoreKit transaction updates, matching the app's launch behavior. Fresh-account UI tests use a temporary copy of the local catalog with a fresh subscription-group identity for each case, retaining both plans in the same group; this isolates introductory eligibility from a previous unit-test process. Trial ineligibility within one group remains covered by the unit test. Injected cancellation/product-loading errors are intentional test cases. Xcode's forced-expiration test uses `AppStore.sync()` to refresh its local receipt before checking entitlements; production access continues to use verified StoreKit entitlements and transaction updates.

## Visual evidence

The two screenshots were exported from the passing final UI test. At the tested 402 × 874-point viewport, the selected full amount, three-day trial action and renewal disclosure are readable. The locked sheet retains its blurred backdrop and ivory photo fade. Review your setup is visible; Restore, Terms and Privacy remain reachable by scrolling. Larger accessibility text sizes were not visually validated in this pass.

The local runtime returned numeric product prices of 35 and 3 while localized prices and paid transaction prices correctly contained 35.88 and 3.99. The app now hides optional computed monthly equivalents and value badges when numeric and display prices disagree; it always displays StoreKit's full localized charge. This prevents a misleading $2.92/month equivalent on the yearly plan.

![Yearly trial](qa-evidence/setup-trial-2026-10-04/paywall-yearly.png)

![Monthly trial](qa-evidence/setup-trial-2026-10-04/paywall-monthly.png)

## Release boundaries

Configure both actual auto-renewable products in one App Store Connect subscription group, set a **Free, 3 Days** introductory offer on both, confirm supported prices/storefronts, and validate new and ineligible accounts, renewal, cancellation, restore and expiration in sandbox. Apple permits one introductory offer per account per subscription group. [Apple configuration guide](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-introductory-offers-for-auto-renewable-subscriptions/).

This native slice still uses placeholder schedule choices. Actual prayer-time calculation, notification delivery, scheduled shielding and physical-iPhone entitlement validation remain separate work, as documented in README. A published privacy-policy URL is also required before release.
