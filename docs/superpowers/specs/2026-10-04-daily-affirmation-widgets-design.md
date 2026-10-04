# Daily affirmation widgets

Date: October 4, 2026
Status: Approved by the user on October 4, 2026. Original affirmations and all three widget families are in scope.

## Purpose

Add daily Muslim affirmations to the existing Prayer Focus iPhone app. Keep the established English-first audience, calm visual style, local storage, and paid membership. The user's new request brings widgets into scope; update the older deferred-widget statements when implementing this feature.

## Content approaches

1. **Original affirmations — recommended:** short first-person reflections about intention, gratitude, patience, hope, compassion, and trust in Allah. Clearly describe them as original reflections. This gives the small widget enough space for the complete text.
2. **Quran and hadith excerpts:** sourced religious quotations with references and reviewed translations. This requires a separate sourced corpus and more room for attribution.
3. **Mixed collection:** both original reflections and sourced quotations, with explicit labels. It offers more variety but introduces two content formats and a larger review scope.

The approved design uses option 1. No text below is presented as a Quran verse, hadith, religious ruling, or promise of a particular outcome.

## Widget experience

- **Small Home Screen:** a restrained crescent symbol, “Daily affirmation,” the complete daily text, and a short theme label. No photography behind text.
- **Medium Home Screen:** the same text with more space, a larger type size, and a restrained arch detail beside the text.
- **Rectangular Lock Screen:** the same complete daily text in the system's monochrome presentation; omit decorative text when it would reduce legibility.
- Use the existing warm ivory, sage, and sand palette on the Home Screen. Support the system's tinted appearance and high-contrast monochrome presentation.
- Use accessible text sizing and VoiceOver reading order: title, affirmation, theme. Test the longest text in each family; revise copy rather than silently truncate it.
- All sizes display the same affirmation for the same local calendar day. Widget instances do not select separate random texts.
- Tapping a widget opens a focused “Daily affirmation” view in the app through a dedicated URL route. Existing membership gating applies before showing this view.
- Settings contains a “Daily affirmations” row leading to the same view, widget previews, and concise instructions for adding Home Screen and Lock Screen widgets. iOS's widget gallery remains the installation flow.
- The affirmation view shows the daily text, theme, and “An original reflection.” The existing prayer journey stays the app's primary screen.
- No push notifications, remote generation, accounts, content feeds, theme picker, or favorites are needed for this first version.

## Daily collection

| Day in cycle | Theme | Original affirmation |
| --- | --- | --- |
| 1 | Trust | I take the next step with trust in Allah. |
| 2 | Intention | I begin again with a sincere intention. |
| 3 | Gratitude | I make room for gratitude in ordinary moments. |
| 4 | Patience | I practice patience, one moment at a time. |
| 5 | Compassion | I choose gentle words for myself and others. |
| 6 | Hope | I turn to Allah with hope today. |
| 7 | Trust | I do my part and entrust the outcome to Allah. |
| 8 | Intention | I bring care and sincerity to my actions. |
| 9 | Gratitude | I notice the blessings I often overlook. |
| 10 | Patience | I give myself time to grow. |
| 11 | Compassion | I can be kind while keeping healthy boundaries. |
| 12 | Hope | I can return to what matters today. |
| 13 | Trust | I ask Allah for guidance as I move forward. |
| 14 | Intention | I make space for salah in my day. |
| 15 | Gratitude | I can feel grateful and acknowledge what is hard. |
| 16 | Patience | I meet this moment with a steady heart. |
| 17 | Compassion | I offer kindness without needing recognition. |
| 18 | Hope | I seek Allah's mercy with an open heart. |
| 19 | Trust | I take a breath and place my trust in Allah. |
| 20 | Intention | I choose one meaningful act of good today. |
| 21 | Gratitude | I pause to appreciate what is here. |
| 22 | Patience | I can pause before I respond. |
| 23 | Compassion | I listen with care before I speak. |
| 24 | Hope | I can begin again after a difficult day. |
| 25 | Trust | I make du'a and take the steps within my reach. |
| 26 | Intention | I give this prayer my attention. |
| 27 | Gratitude | I express gratitude through my actions. |
| 28 | Patience | I choose a small, steady step today. |
| 29 | Compassion | I treat myself with the care I offer others. |
| 30 | Hope | I turn toward Allah with a willing heart. |

## Architecture and data flow

- Add a WidgetKit extension target to the existing XcodeGen project and embed it in the app. Support `systemSmall`, `systemMedium`, and `accessoryRectangular` on the existing iOS 18 deployment target.
- Share a small content module between the app, extension, and tests. It owns the immutable 30-item catalog, theme labels, and deterministic date selection. Keep its date calculations independent of SwiftUI and membership services.
- Derive the catalog index from Gregorian calendar-day distance from January 1, 2026, normalized to the supplied local time zone. Normalize modulo for dates before the anchor. Advance by calendar days rather than 86,400-second intervals so daylight-saving changes behave correctly.
- Prepare a timeline containing the current daily entry and the next seven local day boundaries. Always include the membership expiration, even beyond this content horizon, and separately request a new timeline after the seventh local midnight. WidgetKit controls actual rendering and refresh timing; this is a daily schedule, not a guarantee of an exact midnight refresh.
- Share a verified membership snapshot through an App Group. Save the recognized product identifier and expiration date only after the app's existing StoreKit verification succeeds. Missing, malformed, revoked, and expired snapshots give the locked presentation. Clear the snapshot when refresh finds no verified active subscription.
- Bound access to the recorded expiration date and insert a locked timeline entry at that date. Every later entry must also be locked. Never use a persisted unrestricted `hasAccess` boolean as authorization.
- After a purchase, restore, entitlement refresh, or transaction update changes the snapshot, ask WidgetKit to reload this widget's timelines. Offline revocation awareness remains limited to the last verified snapshot and its expiration; document and test this behavior.
- The locked widget says “Daily reflections” and “Open Prayer Focus to continue.” Its tap enters the existing purchase/restore flow. Widget gallery previews may show a labeled sample; unverified installed widgets do not expose the daily collection.
- App Group capability and matching app/extension signing must be configured for device distribution. Verify the actual host and extension access to the same container before declaring device readiness.
- Register the widget URL route in the app. Preserve a pending affirmation destination while membership is checked or the paywall is presented, then open the affirmation view after access is verified. Coalesce overlapping refresh callers so purchase and restore await the same authoritative result. Close Settings before presenting the pending destination; close member content when access expires.

## Failure behavior

- The catalog is bundled, so a network failure does not remove the daily text for an eligible member.
- Membership data that cannot be read produces the locked state. The app offers its existing restore flow.
- Opening the app after a date or time-zone change selects the current local day's text and requests a widget reload. The extension uses the local time zone whenever it creates its timeline.
- A delayed system refresh may temporarily show the previous entry. No background loop or exact-refresh claim is introduced.
- Unknown widget URL destinations use the existing app entry flow and do not bypass membership.

## Verification and acceptance

1. Build the app with its embedded extension and pass the existing prayer state and membership UI checks.
2. Add meaningful unit coverage for same-day stability, cycle rollover, dates before the anchor, leap day, DST boundaries, and time-zone date changes.
3. Verify membership snapshots for missing, malformed, active, revoked, and expired data; verify that a timeline transitions to locked at expiration and contains no accessible entries afterward.
4. Verify widget taps while membership is active, while checking access, and while locked; successful purchase/restore resumes the intended affirmation destination.
5. Inspect all three widget families with the longest text, VoiceOver, and tinted/monochrome appearances. No hidden text or unreadable contrast.
6. Confirm app and widget show the same text for the same local day and continue to work offline when the recorded membership is active.
7. On a signed physical iPhone, add each family from the gallery and verify App Group reads, daily rollover, deep links, purchase/restore reloads, and expiration. Report simulator checks and device/StoreKit checks separately.

## References

- [Apple: Widget families](https://developer.apple.com/documentation/widgetkit/widgetfamily/)
- [Apple: Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date/)

## Approved scope

The user approved the original-reflection approach and the three-family scope with “ок, двигаемся дальше”. Execute in the current worktree. Sourced Quran/hadith excerpts would require a separately reviewed corpus and attribution requirements.
