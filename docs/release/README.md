# SalahSide release preparation

Prepared October 5, 2026, on `codex/salahside-release`, rebased onto live `origin/main` commit `87c48b741187d60d753642f56ed857236920d837` (merged setup/trial work). Work is isolated in a managed worktree; the original checkout's uncommitted documents and native/prototype files were preserved.

**Status: local release candidate preparation. App Store distribution remains blocked on owner configuration, website publication and real-device acceptance. No build has been uploaded or submitted.** The owner selected a direct App Store release; a separate TestFlight release is not required by this plan.

## Changes available for review

SalahSide branding, version 1.0.0/build 1, app icon, actual city-local prayer times, Asr/high-latitude/manual adjustments, private persisted check-ins, notification scheduling, Screen Time monitor/shield/action extensions, one-hour pause, local-data deletion, privacy manifests and native CI are implemented. The paid setup-first trial flow and daily affirmation widgets remain part of the app. Technical bundle and subscription identities were preserved.

The icon was generated with the built-in imagegen tool from the approved architectural direction; its saved path and full prompt are recorded in [asset provenance](asset-provenance.md). Existing app artwork was retained.

The public site includes landing, Privacy Policy, Terms, Support, and 404 pages. [Website preparation](../../front/README.md) and [browser QA](site-qa.md) explain publication fields and verification. The website has not been deployed.

## Local evidence

| Check                                                                | Result                                                                             | Evidence                                                      |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| Rebase on current main                                               | Completed                                                                          | Release branch based on `87c48b7`                             |
| Unit tests: schedule, focus, persistence, calendar and widget policy | 43 tests, 0 failures                                                               | `/private/tmp/salahside-reviewed-unit-tests.xcresult`         |
| Setup/trial/paywall/privacy/erase tests                              | 16 unit + 6 UI, 0 failures                                                         | `/private/tmp/salahside-trial-repair-tests.xcresult`          |
| Upstream calculation reference fixtures                              | 51 tests, 0 failures                                                               | `/private/tmp/salahside-adhan-final-tests.log`                |
| Widget StoreKit/deep-link integration                                | 2 unit + 3 UI, 0 failures; normal simulator signing                                | `/private/tmp/salahside-widget-storekit-final-tests.xcresult` |
| Strict native Swift formatting                                       | Passed                                                                             | `/private/tmp/salahside-swift-lint.log`                       |
| Release archive and structural preflight                             | Passed: app + four embedded extensions, versions, icon, manifests, no test fixture | `ios/PrayerFocus/build/SalahSide.xcarchive` (unsigned)        |
| Website build, types, lint, formatting, browser                      | Passed locally; 320–1505px, disclosures and navigation                             | [Site QA](site-qa.md)                                         |
| Remote iOS CI                                                        | Configured; not run                                                                | `.github/workflows/ios.yml`                                   |
| Physical device / sandbox / App Store                                | Not validated or uploaded                                                          | [Device acceptance log](physical-device-qa.md)                |

The full distribution preflight correctly fails for missing public policy, real Team ID and distribution signatures/capabilities; those owner gates are still open. One initial unsigned widget integration run lacked App Group access; the final signed simulator run passed after synchronizing the local StoreKit receipt on fixture reset/purchase. This is simulator evidence only.

Project whitespace validation passed with the unchanged Adhan `Sources` and `Tests` excluded. Those upstream files retain their original trailing whitespace to preserve the verified upstream content; they are also excluded from the native formatter.

The preview images under `screenshots/` are actual simulator captures using a local StoreKit test fixture. They are review evidence, not live billing or device proof.

## Owner configuration required

| Item                                  | State / next action                                                                                                                                                  |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Apple Developer Team ID               | Not supplied; apply one real team to all five targets                                                                                                                |
| App IDs and App Group                 | Register app/Widgets/Monitor/Shield/ShieldAction and `group.com.marsolab.PrayerFocus`; assign the group to app, Widgets, Monitor and Shield                          |
| Family Controls distribution approval | Required for app, Monitor, Shield and ShieldAction; not confirmed                                                                                                    |
| Monthly/yearly live products          | IDs `com.marsolab.PrayerFocus.monthly` / `.yearly`, one group, eligible 3-day free offer, supported real prices; not confirmed                                       |
| Published privacy policy              | Owner/legal name and support email missing; [website policy](../../front/src/pages/privacy.astro) and [draft](privacy-policy-draft.md) ready to complete and publish |
| Public support URL/email              | Not supplied; complete App Store metadata                                                                                                                            |
| Signing/distribution profiles         | Not configured/validated for this candidate                                                                                                                          |
| Domain/name reservation               | October 4 availability is a snapshot; no purchase, registration or App Store Connect reservation was performed                                                       |

Apple's [Family Controls distribution process](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement) covers the app and each Screen Time extension. Apple's [review guidelines](https://developer.apple.com/app-store/review/guidelines/) require an accessible privacy policy. The project manifest is separate from that policy.

## Acceptance before upload

Complete the [physical-device log](physical-device-qa.md), including scheduled shield/clear while foreground/background/killed, restart, app self-access, categories/websites, finish/already prayed/unlock, pause expiry, disabled next prayer, permission revocation and subscription expiry. Record StoreKit sandbox trial, renewal, cancellation, ineligibility, pending purchase, restoration and revocation. Verify all widget families and App Group sharing on a signed physical iPhone.

Have a qualified reviewer compare prayer conventions and matching timetables for supported cities, especially high latitude/DST and Umm al-Qura Ramadan adjustments. Confirm accessible VoiceOver/larger-text flows and the approved usability beta criteria from the PRD.

Device Activity event delivery is device-use dependent ([Apple schedule documentation](https://developer.apple.com/documentation/deviceactivity/deviceactivityschedule/nextinterval)), and its [minimum interval is 15 minutes](https://developer.apple.com/documentation/deviceactivity/deviceactivitycenter/monitoringerror/intervaltooshort). The code uses finite windows, checks saved membership expiry and releases restrictions on invalid state. Local policy tests do not prove real-time platform delivery. Offline refund awareness is limited to the latest app verification; reopening refreshes entitlement state.

## Distribution workflow

1. Complete and publish the [website](../../front/README.md), then owner fields in [App Store draft](app-store-metadata.en-US.json), [privacy-policy draft](privacy-policy-draft.md) and [review notes](app-review-notes.md).
2. Copy `ios/PrayerFocus/Configuration/Release.example.xcconfig` to ignored `Release.local.xcconfig`. Set the actual team and published HTTPS policy URL.
3. Archive with the real distribution-capable team, then run `scripts/release_preflight.py` without `--structural-only` and with the real Team ID. The script checks signatures, team/capabilities, versions, manifests, icon and embedded extensions, and rejects a bundled test fixture.
4. Complete the device/sandbox evidence above. Copy and fill `ExportOptions.example.plist` for a local export; its destination is export, not upload.
5. After the concrete package and evidence are reviewed, upload the signed candidate to App Store Connect, verify processing, attach the first subscriptions to version 1.0.0, complete metadata and screenshots, then submit that version for App Review. None of these external steps has been performed in this task.

The preflight script's successful signed-artifact result is an artifact check. It does not confirm App Store Connect configuration, capability approval, policy contents, App Store build processing or device acceptance.
