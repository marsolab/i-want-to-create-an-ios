# Product Requirements Document — SalahSide beta

Version 0.5 · October 4, 2026 · Setup before a three-day membership trial, with daily affirmation widgets

This revision replaces the earlier 14-day journey as the first product. The initial beta tests whether an opt-in iPhone focus mode can help English-speaking Muslims make room for salah. App name and final brand remain open.

## 1. Product direction

**Promise:** Make space for salah by pausing the apps that distract you when prayer time begins.

The user selects distracting apps and permits Screen Time controls. By default, focus is enabled for all five daily prayers. At each enabled prayer's scheduled time, the selected apps are shielded. The user can mark that they are starting prayer, put the phone away, then mark that they have finished. They can also mark a prayer as already completed without the phone. Either confirmation clears the app's restriction for that prayer. An explicit “Unlock for this prayer” action clears the restriction without marking the prayer complete.

The app records the user's own actions; it does not verify worship. A missing confirmation is displayed as “No check-in,” not as a known missed prayer. Restrictions never accumulate across prayers. At the next prayer event, the prior restriction is cleared and the next enabled prayer starts its own focus period. If the next prayer has focus disabled, the prior restriction is cleared without starting another.

This is a voluntary focus tool, not a device-wide lock. The user can deselect apps, pause focus, or revoke Screen Time authorization in iOS Settings. Explain those controls before enabling the feature. Never claim to control the whole phone or guarantee that restrictions cannot be bypassed.

## 2. Audience and release scope

- **First market:** English-speaking Muslims worldwide. Start with English UI and local prayer times; do not assume a launch country until access to beta participants is confirmed.
- **Later languages:** Arabic, then Persian, then other languages. Design layouts and content for right-to-left direction and text expansion from the beginning; translations are not part of this beta.
- **Beta platform:** native iPhone app. No Android, web substitute, account, cloud sync, advertising, or social features. The paid membership design is included; live billing remains gated on product configuration and core feature validation.
- **Included:** five-prayer schedule, configurable prayer-time settings, optional Screen Time focus for selected apps, one prayer-start notification where authorized, local check-ins, a user-controlled pause/unlock path, and daily affirmation widgets.
- **Excluded:** Qibla, Qur'an reader, 14-day lessons, journal, and analytics tracking. Revisit these only after the core use case is validated.
- **Default:** focus enabled for all five prayers. Users can switch each prayer's focus off independently; prayer times remain visible and check-ins remain available.

## 3. Main experience

### First run

1. Explain the benefit, what will be restricted, and the always-available pause, per-prayer settings, and iOS authorization controls. Show a sample focus screen.
2. Let the user choose a city manually or grant foreground location access. Do not request background location.
3. Show the resulting prayer schedule, time zone, calculation method, and adjustable settings so the user can compare against a trusted local timetable.
4. Let the user select distracting apps and sites with Apple's system picker; do not preselect any apps.
5. Explain that authorization is required for focus, then request it. If declined, keep the schedule and allow reminders/check-ins without restrictions.
6. Confirm all five prayer switches are on by default and show the selected apps and next focus time.
7. Save the complete setup locally, then present membership in a large sheet that slides up from the bottom before granting product access and activating focus. Offer a three-day free introductory trial followed by monthly or yearly billing. The trial begins only when Apple confirms the subscription. The paywall has no close button or swipe-to-dismiss path; users can review their setup without unlocking product access. It dismisses only after a verified purchase or restoration of an active subscription, including an active trial.

### Membership

- Membership product with no permanent free tier. Eligible Apple Accounts receive a three-day free introductory trial on either the monthly or yearly plan. After the trial, Apple bills the full monthly or yearly amount for the selected plan, then renews at that interval unless cancelled.
- Users can configure location, calculation method, distracting apps, prayer switches, and notification preferences before the paywall. Store these choices and setup completion locally so returning to the app or cancelling payment does not lose setup.
- Paywall uses a large native sheet with rounded top corners. Remove the close control and drag indicator; disable interactive dismissal while there is no active subscription. Pending, cancelled and failed purchases leave the paywall open. Restoring an existing active subscription also unlocks access.
- Selected mosque-and-arch paywall with the headline “Make space for salah.” Annual is selected by default.
- Blur the presenting image behind the sheet, including the status-bar safe area. Keep the paywall sharp and fade the lower photo edge into the ivory canvas. The presenting surface must not accept touch or accessibility interaction while the paywall is open.
- Annual offer prominently displays the full **$35.88/year**, with **$2.99/month** as an optional secondary equivalent when StoreKit's numeric and localized prices agree. Monthly is **$3.99/month**. For eligible accounts, the selected-plan disclosure reads “3 days free, then [full price]/[year or month]” and the action is “Start 3-day free trial.” Display automatic renewal and cancellation information beside the purchase action.
- These are the approved design amounts. Select supported actual App Store prices before release; use localized StoreKit prices and compute the annual monthly equivalent from the actual billed price divided by twelve. Hide the optional equivalent and value comparison if StoreKit's numeric and display prices disagree; always retain the full localized charge.
- Subscribe and Restore use Apple StoreKit. Configure both products in one subscription group with a free introductory offer of three days. Check actual product metadata and account eligibility before advertising a trial; an account that has already consumed the group's introductory offer sees ordinary upfront pricing and “Subscribe.” A product that is missing or has a different eligible introductory offer must never receive a fabricated three-day-trial promise. Grant access only from a verified, active subscription or trial. Cancellation, pending/unverified transactions, unavailable products, and expired or revoked subscriptions do not grant access.
- Never require payment to clear existing app-owned restrictions. Clear those restrictions when access expires before returning to the membership gate; this remains part of real-device shielding validation.
- Keep Restore purchases, Terms and Privacy visible. No fake ratings, urgency, religious guarantees or guilt language.

### Daily use

- **Today screen:** next prayer and time, focus status, primary action, and a compact list of the five prayer times with independent focus switches accessible in settings.
- When an enabled prayer starts, selected apps show a calm, branded shield that names the prayer and offers a route to SalahSide. The SalahSide app itself remains accessible.
- The app shows “Start prayer.” After the user taps it, it shows a quiet “Your phone is ready to be put away” state and a “Finish prayer” action on return. The screen may be locked during prayer; there is no required timer or minimum duration.
- “Already prayed” ends the restriction and stores a self-reported completion without requiring a start/finish sequence.
- “Unlock for this prayer” ends the restriction without recording completion and asks for one brief confirmation to prevent accidental taps. Do not require a reason.
- There is no snooze-by-default and no repeated nagging. One notification at the start of an enabled prayer is scheduled only if notifications are allowed. Its permission is optional and independent of Screen Time authorization.

### Visual direction

Use a calm, warm-light foundation: warm white or milk surface, muted sand, a restrained sage accent, readable typography, and generous spacing. The selected visual direction may use a mosque and architectural arch as the main scene; keep that imagery spacious and let the prayer action remain clear. Remove the app-name masthead and secondary slogans from the main focus screen. Keep the shield respectful and reassuring, with a single clear route back to the prayer action. Avoid ornamental overload, gamified scores, guilt language, and visual claims of religious authority. Refine type size, rhythm and spacing before interface implementation.

### Daily affirmations

- Include 30 original English reflections on trust in Allah, intention, gratitude, patience, compassion, and hope. Identify the content as original reflections; do not present it as Quran or hadith quotations.
- Offer small and medium Home Screen widgets and a rectangular Lock Screen widget. Keep complete text readable in full-color, tinted, and monochrome contexts.
- All instances and the app select the same reflection for the current local Gregorian calendar day. The catalog repeats after 30 days and works offline.
- Widget taps open the daily affirmation view after membership verification; a request made while checking access or presenting the paywall resumes once access is confirmed. Settings also links to the view and installation guide.
- Share only recognized verified StoreKit product IDs and their expiration dates through an App Group. Missing, malformed, revoked, or expired access uses a locked widget. Timeline entries include the subscription expiration boundary.
- WidgetKit schedules actual updates; do not promise exact midnight rendering. Offline revocation awareness is limited to the latest verified snapshot and its recorded expiration.
- The prayer journey remains the primary app screen. The widget feature adds no notifications, accounts, remote generation, favorites, or analytics.

Detailed design: [Daily affirmation widgets](superpowers/specs/2026-10-04-daily-affirmation-widgets-design.md).

## 4. Prayer schedule and settings

- Show Fajr, Dhuhr, Asr, Maghrib, and Isha every day. Sunrise may be shown as a clearly labeled reference, not as a prayer.
- Support manual city selection without location permission. If using current location, request foreground access only and show the selected city/time zone.
- Make calculation method, Asr convention, high-latitude handling where relevant, and per-prayer minute adjustments visible and editable. Do not present a hidden universal default.
- Initial default method and supported jurisprudential conventions require qualified subject-matter review before public beta. The user can choose a locally trusted method and compare displayed results with their mosque.
- Recalculate after a settings, date, location, or time-zone update. If the device travels while the app is closed, refresh on next open and make schedule freshness visible. Do not promise background travel tracking.
- If a valid schedule cannot be calculated, explain why, offer manual location/settings, and do not fabricate prayer times or start a focus period based on stale data.

## 5. Focus behavior and failure states

- Restrict only user-selected applications/categories/web domains using Apple's Screen Time APIs. The app itself and essential system functions remain available.
- A focus interval begins at the configured time for an enabled prayer. It ends on “Finish prayer,” “Already prayed,” “Unlock for this prayer,” or when the next prayer event is processed. A next prayer with focus disabled still clears the previous interval.
- Repeated or delayed schedule events must be idempotent: processing the same prayer event twice must not create a second state or reapply a cleared restriction.
- A pause suspends focus until the selected end time or manual resume; selecting pause clears current app-owned restrictions. No explanation is requested.
- If Screen Time permission is denied or revoked, do not claim focus is active. Keep prayer schedule and local actions working, show the status, and offer a direct settings explanation.
- If scheduling is stale or an extension cannot determine the current prayer safely, clear app-owned restrictions rather than leave selected apps blocked indefinitely. Show a recoverable notice when the app next opens.
- Prayer logs stay private on device. The UI describes check-ins as self-reported and offers clear/delete-all controls.

## 6. Data, privacy, accessibility

- No account or application server is required. Store prayer settings, selected app tokens, pause state, and check-ins locally and share only the minimum necessary state with the Screen Time extensions through an app group.
- Use opaque system app-selection tokens. Do not collect app usage reports or upload selected app identities, prayer times, precise coordinates, check-ins, or pause reasons.
- Assess and accurately disclose device backup behavior before claiming data never leaves the phone. No third-party behavioral analytics SDK in beta.
- Make check-ins editable or deletable and provide a single explicit erase-local-data action. Deleting app data cannot reverse a user-created export or device backup; no export is required in beta.
- Support Dynamic Type, VoiceOver labels, high contrast, reduced motion, and non-color-only focus states. Keep copy and layout ready for English expansion and Arabic/Persian right-to-left localization.

## 7. Native implementation and platform gate

- Build a native SwiftUI iOS application with a small local domain layer for prayer schedules, focus state transitions, settings, and check-ins.
- Use FamilyControls for individual authorization and app selection, ManagedSettings to shield the selected targets, and DeviceActivity extensions to handle scheduled state changes while the main app is closed. Use UserNotifications for the optional start notification.
- Before full UI build, make a technical spike that proves a selected app is shielded at a scheduled event and unshielded after each completion/escape path, including while the app is backgrounded. Confirm target OS support and extension behavior against current Apple documentation.
- Apple requires the Family Controls capability and approval for distribution. Request the entitlement early; TestFlight/App Store distribution is gated on approval. If approval is unavailable, keep the project in design/research and do not present a non-functional imitation as the promised hard mode.
- Keep all state transitions deterministic and locally testable; extensions and the app must read/write a shared, versioned focus state safely.

## 8. Acceptance and validation

### Functional acceptance

- With authorization granted, the user can choose apps and see them shield at a scheduled enabled prayer, including after the app is backgrounded or the phone is restarted.
- Finish, already prayed, per-prayer unlock, pause, disabled next prayer, and permission revocation each restore the expected access without creating false completion records.
- No prior unchecked prayers accumulate. The next enabled prayer is the only active focus interval.
- All five prayer times remain visible when focus is disabled for any subset of prayers. Time settings are reviewable and adjustments affect the next schedule.
- Offline use works after initial city/method setup. A stale or invalid schedule never applies an indefinite restriction.

### Test matrix

- Unit tests: local prayer event ordering and date rollover; focus state machine; idempotent event delivery; lock → start → finish; already prayed; manual unlock; pause expiry; focus-disabled next prayer; permission loss; stale schedule fail-safe.
- Real-device checks: Screen Time authorization approved/declined/revoked; picker selection changes; shield action and app return; screen lock during prayer; app killed/backgrounded; device restart; daylight-saving and time-zone update; notification permission denied; offline schedule; accessibility with VoiceOver and larger text.
- Schedule fixtures: representative cities and dates across supported calculation conventions, including high latitude and DST transitions. Compare only against references using matching conventions; record unresolved material differences as release blockers.
- Affirmation widget checks: calendar-day stability, cycle wrap, leap day, DST and time-zone transitions; missing/malformed/revoked/expired membership; expiration timeline entries; membership-gated widget links; all three families, longest text, system tinting, and VoiceOver. Verify App Group sharing and purchase/restore reloads on a signed physical iPhone before release.
- Usability beta: 15–20 consenting English-speaking adults where recruitment is accessible. At least 4 of 5 observed participants should independently configure focus and understand how to finish or unlock. Collect voluntary feedback; do not upload individual prayer check-ins.

### Release gates

- Zero known cases of restrictions remaining indefinitely after an error, pause, disabled next prayer, or permission revocation.
- Users can explain what will be blocked, how they can clear it, and that check-ins are self-reported.
- Qualified reviewer signs off the initial supported prayer-time conventions and terminology.
- Apple distribution entitlement is approved before any claim of App Store or TestFlight readiness.
- Privacy disclosures, support contact, and current limitations match observed behavior.

## 9. Success measures

Success is whether the voluntary tool is understandable, technically dependable, and useful to its users. It is not a measure of faith or religious worth.

- **Setup completion:** users who finish schedule and Screen Time setup divided by those who begin setup; report counts and permission declines separately.
- **Core reliability:** successful scheduled shield/clear transitions divided by observed device test transitions; target 100% in release test cases, with zero indefinite-shield failures.
- **Usability:** at least 4/5 observed participants independently configure, start and finish or unlock focus.
- **Perceived usefulness:** voluntary participant feedback on whether focus helped create room for salah; present sample size and unknowns, not as proof of religious adherence.
- Do not track prayer completion for product analytics or send individual worship data to a server.

## 10. Delivery sequence

1. Finalize three visual directions and select one before building app screens.
2. Complete the Screen Time technical spike and request Apple distribution entitlement.
3. Validate time settings and content terminology with a qualified reviewer.
4. Implement local prayer schedule, focus state flow, permission onboarding, and selected-screen designs.
5. Test on real iPhones and run a small consented English-language usability beta after platform and privacy gates pass.

Name, supported initial calculation defaults, first recruitment community, and final typography/icon remain open. Do not make these unresolved choices invisible in the interface.
