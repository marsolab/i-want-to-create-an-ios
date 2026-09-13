# Product Requirements Document — Deenstead

Version 0.1 · September 13, 2026 · Proposed scope for founder approval

Brand is deliberately unresolved. See [naming options](app-names.md), [marketing strategy](marketing-strategy.md), and the [earlier market research](muslim-ios-app-market-opportunity.md). This PRD narrows the earlier proposal to fit a zero-cash validation phase. It is a specification, not a claim that the product, reviewers, or partnerships already exist.

## 1. Product decision

Build a private iPhone companion that helps English-speaking Muslims return to a consistent salah routine after interruptions. Its first experience is a free, self-paced **14-day Reconnect With Salah journey**, supported by prayer times, Qibla, and optional reminders.

Working promise: **“Return to your salah routine, one day at a time.”**

The interaction is small: read a short, sourced teaching; choose a practical action; optionally reflect later. Aim for 2–5 minutes in the app. Worship and actions happen outside it; prayer itself is not included in that time estimate.

The app supports the user's practice. It never defines how good a Muslim someone is, calculates spiritual worth, or treats engagement as evidence of faith. Focusing on one practical change is a learning technique, not a recommendation to omit other religious obligations.

### What is and is not established

Prayer tools and Islamic habit apps are crowded. Further research also identified **Niyyah**, whose current listing explicitly describes short, scholar-developed journeys ending in concrete actions, alongside an AI companion and streaks. The learning-to-action loop is therefore already served; it is not a defensible novelty claim. [Niyyah's developer listing](https://play.google.com/store/apps/details?id=com.guider.guidermobile)

Our hypothesis is that a specific cohort prefers a smaller, restart-friendly experience with local private notes, no mandatory account, no streak penalties, transparent source review, and no AI religious adviser. Validate that preference against existing products. No evidence yet establishes an underserved market or willingness to pay for this exact combination.

## 2. Audience and jobs

**Primary participant:** an English-speaking adult iPhone user who already knows the basics of salah, has struggled to maintain a routine through work, travel, or other interruptions, and wants a manageable way to return.

Recruit initially through one or two accessible English-speaking communities. UK and UAE English-speaking communities are candidate starting points; choose based on actual access to participants and reviewers, not an assumed distribution advantage. Do not attempt a global multilingual launch.

Core jobs:

- “When my routine breaks, help me return without feeling that all my previous effort was erased.”
- “Show me the next prayer using settings I understand and can compare with my mosque.”
- “Help me act on one useful teaching instead of saving another quote.”
- “Let me keep my reflections private.”

These are proposed interview hypotheses, not verbatim customer quotations.

**Not the first audience:** children, users seeking a complete learn-to-pray curriculum, advanced Islamic study, clinical mental-health support, or family monitoring. New Muslims can use suitable content, but v1 must not imply that it teaches all prayer requirements.

### Problems to test before engineering

Interview 15–20 adults about their last actual interruption, current tools, what they abandoned, and what helped them return. Let at least five compare this prototype with their existing app and Niyyah or another relevant alternative. Ask what, if anything, is sufficiently useful to keep both or switch. If the answer is only “prettier prayer times,” revise the proposition before building.

## 3. Budget and delivery stages

Zero budget means zero new cash spending, assuming the founder already has suitable equipment, internet access, and time. It does not make development, support, or editorial work costless.

| Stage | Deliverable | Cash boundary | Exit condition |
|---|---|---|---|
| A: problem validation | Interviews, three simple screens, name test | $0 using existing tools | Repeated problem, reachable cohort, plausible reason to use this over alternatives |
| B: concierge pilot | Reviewed 14-step journey on a simple mobile page/document; opt-in reminders through an existing channel | $0 only if content rights and competent review are available without payment | At least 20 activated participants with completed observation windows; retention and trust gates below |
| C: native beta | Free local-first iPhone app with P0 features | Existing developer membership or separately approved membership cost | Content, prayer calculation, reminders, privacy and usability pass |
| D: first revenue | One finished, reviewed additional journey | No paid acquisition required | Real purchases and continuing use justify further content investment |
| E: subscription | Sufficient complete content and sustainable ongoing service | Funded by revenue; budget approved separately | Recurring value demonstrated, not merely promised |

Apple lists developer membership at **US$99 per year**, with regional pricing and limited fee-waiver eligibility. Budget for it unless an existing membership covers this project; do not assume a commercial app qualifies for a waiver. Public TestFlight/App Store delivery is a different step from free prototype testing. [Apple enrollment](https://developer.apple.com/programs/enroll/), [developer account overview](https://developer.apple.com/help/account/basics/about-your-developer-account)

If no qualified reviewer volunteers, use the free phase for interviews and interface testing with clearly marked placeholders. Do not release unreviewed religious guidance to meet a calendar deadline. Reduce content scope or fund review first.

## 4. Scope and priorities

P0 is required for the first public native release. The concierge pilot only needs the journey and consented feedback, not native prayer infrastructure.

| Capability | P0 free release | Later, evidence-dependent |
|---|---|---|
| Prayer times | Five daily prayers, sunrise separately labeled, next-prayer display, visible location/method settings, manual adjustments | Verified mosque timetable import and broader regional support |
| Qibla | Direction, bearing, accuracy/permission states; manual-city fallback clearly approximate | Map alignment and additional guidance |
| Reminders | Optional prayer reminders and user-selected journey reminders, independently controlled | Additional reminder styles only after demand |
| Daily guidance | One reviewed 14-step starter journey; source and context visible | More reviewed journeys, optional audio with rights |
| Reflection | Optional local text note, edit/delete/export | Optional private sync with a separately reviewed data design |
| Return experience | Resume, repeat a step, pause, or restart without lost progress | User-controlled routine personalization |
| Prayer widget | One basic next-prayer widget, free | Additional widget layouts; do not remove existing free utility |
| Sharing | User-initiated generic journey invitation | Reviewed source-card sharing after attribution QA |
| Payments | None in beta; free core stays accessible | One-time journey purchase, then subscription if justified |

**Explicitly excluded:** full Qur'an reader or recitation catalog, open-ended AI scholar/chatbot, fatwas, social feed, public prayer logs, streak repair purchases, piety/reward points, family surveillance, donations/zakat handling, mosque discovery directory, halal marketplace, Android, standalone Watch app, and a custom content-management backend.

“Daily affirmation” becomes **daily intention/reflection**. Original encouragement must be labeled as editorial writing, visually separate from Qur'an, hadith, translation, and scholarly commentary. No generated or paraphrased text presented as scripture.

## 5. Experience and navigation

Three primary destinations: **Today**, **Journey**, **Reflection**. Settings is a secondary destination. Qibla opens from the prayer panel on Today. Avoid a dashboard of dozens of tools.

### First session

1. Explain the promise and show a representative teaching/action card. No forced account or payment screen.
2. Let the user choose a city manually or grant location access after seeing why it helps. Do not request background location.
3. Show the selected prayer calculation configuration and let the user change it or compare with their mosque. Never claim a preset is universal.
4. Start the first journey step. The user can read it before enabling notifications.
5. Offer reminder choices at the point of value. Declining must not block anything else.

Target: at least 4 of 5 observed usability participants can reach and choose the first action within two minutes without founder help. This is a test target, not existing performance evidence.

### Daily use

`Today → next prayer and settings → short teaching → choose action → leave app → optional reflection`

The day card has a source reference, a short explanation, one suggested action, “Choose this action,” “Choose a simpler version” where editorially appropriate, and “Read source.” The action is not automatically recorded as performed.

Evening reflection offers a short question, optional note, and “Skip.” Choosing or completing an app step does not assert a prayer was performed. A skipped reflection must not prevent continuing.

### Returning after a gap

Show: “Welcome back. Continue where you left off?” with Resume and Choose another step. Preserve prior work. No red missed-day calendar, debt count, guilt notification, or automatic reset. Allow the user to pause without stating a reason; never require disclosure of menstruation, illness, travel, or other sensitive circumstances.

After the 14 steps, the free experience offers revisiting steps and saved reflections. Reused material is visibly identified as a revisit. Do not promise a fresh free lesson every day forever with a 14-lesson library.

## 6. Functional requirements and acceptance criteria

### F1 — Prayer calculations

- Store location choice, coordinates needed for calculation, time zone, calculation-method identifier, Asr convention, high-latitude handling, and per-prayer offsets on device.
- Let users inspect/change relevant settings. Initial supported methods and jurisprudential scope require reviewer sign-off; list limitations openly rather than selecting an invisible universal default.
- A manual city works without location permission or network after setup. Approximate city-center coordinates are labeled accordingly.
- Recalculate displayed times and pending reminders after relevant settings, location, date, or time-zone changes. Travel while the app is closed must not be advertised as automatically handled; ask users to reopen and confirm location on arrival.
- Never show a fabricated time when a calculation cannot be produced; explain the limitation and ask the user to use a trusted local timetable.

**Acceptance:** automated fixtures for at least ten representative cities and four seasonal dates, including a high-latitude case, DST transitions, no-DST locations, midnight rollover, and travel across date/time zones. With identical coordinates, method and rounding, expected arithmetic results agree within one minute. Local mosque differences require documented reconciliation of method/offsets; do not apply the one-minute rule to unlike religious conventions. All unexplained discrepancies block release in that supported location.

### F2 — Qibla

- Show numerical bearing and compass direction with an uncertainty state.
- Explain magnetic interference and permission/sensor limitations. Never show a confidently locked arrow when heading accuracy is poor.
- Manual-city mode uses approximate city location; let users inspect this assumption.

**Acceptance:** independently checked bearings across the supported test locations; real-device checks away from interference and with intentionally poor heading data. Missing location or heading must produce a useful explanation, not a crash or false precision.

### F3 — Reminders and widget

- User controls each prayer reminder independently. Default journey reminders to off until selected; maximum two journey prompts per day. Prayer reminders are separate and also opt-in.
- Use scheduled local notifications so a server is not needed for normal delivery. Reconcile pending requests rather than accumulating duplicates. Account for dates that change prayer time; do not repeat yesterday's time indefinitely.
- Engineering must demonstrate at least seven days of correctly scheduled reminders without reopening, within the supported device's pending-notification limits. Show “Scheduled through [date]” and refresh on app open. If safe automatic replenishment is not proven, clearly instruct weekly reopening; do not promise indefinite unattended delivery.
- A disabled permission, disabled sound, or user suppression state is not “reminders are working.” Display status, permit silent reminders, and provide settings guidance. Never promise to override Focus, silent settings, or device shutdown.
- Use a normal licensed sound or system tone in v1. No promise of full-length background adhan playback.
- Widget shows location and schedule freshness and remains readable when data needs updating. It is informational, not a guaranteed second-by-second countdown.

**Acceptance:** real-device tests of allowed/denied/revoked notification permission, changed preferences, duplicate prevention, seven-day closed-app operation, offline use, restart, time-zone change after reopening, and widget freshness. Distinguish scheduled-request success from observed notification delivery. Document any OS-dependent behavior in help text.

These requirements follow Apple's permission-dependent notification model and support for inspecting/canceling scheduled requests. [Notification authorization](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications), [local notification scheduling](https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app)

### F4 — Journey and reflection

- Bundle all approved starter content for offline access. No login required.
- A journey has an ordered sequence but is self-paced; missed calendar days do not skip content.
- A step can be revisited; choices and notes survive app restarts and app updates.
- Reflection is optional. Export is initiated by the user with a warning that the exported file may contain private material.
- Delete one note or erase all app-owned personal data with explicit confirmation. Explain that deletion cannot erase files the user previously exported.

**Acceptance:** complete all 14 steps offline; pause for several simulated days; resume on the correct step; edit/delete a note; export; erase; restart; verify no personal content remains in app storage or pending personal reminders. Test interrupted writes and version migration without data loss.

### F5 — Sources and correction

- Each published religious teaching has a durable source reference, translator/edition where relevant, content version, contextual explanation, rights record and reviewer approval.
- “Report a content issue” opens a user-controlled draft including the content ID/version only by default. It never attaches private notes or prayer settings automatically.
- A serious source or meaning error stops further distribution/promotion of that content, receives reviewer triage, and leads to a corrected build. With an offline bundled library, already-installed offline copies cannot be remotely recalled; communicate that limitation and issue an update prominently.

**Acceptance:** every shipped card passes the checklist; an unsourced or unapproved card fails the release gate. App Store rules explicitly identify inaccurate/misleading religious quotations as unacceptable. [Apple review guidelines, 1.1.5](https://developer.apple.com/app-store/review/guidelines/#objectionable-content)

## 7. Editorial requirements

One accountable reviewer with relevant qualifications must approve the narrow starter curriculum, with a documented second opinion for disputed material. A name on the website is used only with consent and an accurate description of the review performed. A general religious affiliation is not proof of subject expertise.

Content pipeline:

`Proposed topic → source and rights check → original explanation/action → religious review → language/accessibility check → versioned approval → release`

Content record fields: `content_id`, `journey_id`, `step_number`, `source_type`, `source_reference`, `exact_text`, `translation_credit`, `context`, `editorial_action`, `reflection_prompt`, `rights_evidence`, `reviewer`, `approval_date`, `content_version`.

- Keep original Arabic, translation, paraphrase and commentary distinguishable. Do not excerpt in a way that changes meaning.
- For hadith, include collection/reference and the attribution of any authenticity grading. Avoid disputed rulings in the initial general routine content.
- Qur'an translations, recordings, fonts and artwork need their own rights checks. A public page or accessible API does not establish redistribution rights.
- Tanzil is a candidate Arabic-text source; its published terms require unchanged text, attribution and a link. This is not blanket permission for every translation or audio file. Select the exact licensed editions before implementation. [Tanzil terms](https://tanzil.net/docs/text_license)
- No fear-based purchase messaging, promises of guaranteed reward, or health-treatment claims.

Proposed 14-step outline, subject to review: understand your present routine; inspect time settings; prepare a practical prayer space; reduce one predictable distraction; plan for a busy workday; revisit the meaning of a familiar phrase; reflect on week one; respond to an interruption; prepare for travel; connect a daily cue to preparation; make room for a brief Qur'an reflection; identify one source of support; choose what to keep; write a continuation plan. These are editorial topics, not religious rulings or finished lessons.

## 8. Data, accessibility, and implementation boundaries

Prefer a native iPhone app with local storage, bundled content and on-device calculations. The PRD does not lock an implementation library or deployment target; select those after an engineering spike and checking participant device versions. A web/document pilot is a validation asset, not a replacement promise for the eventual iOS product.

No custom backend, account, advertising SDK, behavioral ad targeting, public profile, or remote journal processing in v1. Store no religious-practice history on a marketing service. Existing device/OS backup behavior must be assessed and disclosed accurately; “we do not receive your notes” is a safer claim than “your data can never leave your phone.”

Minimum accessibility: scalable text, legible contrast, full VoiceOver labels, Arabic right-to-left rendering inside an English interface, reduced-motion support, and no information conveyed by color alone. Verify largest supported text sizes and long translated content without truncating scripture.

Analytics boundary:

- App works with measurement disabled. For early beta, use explicitly consented feedback and optionally user-shared local summary counts; do not install a tracking stack merely to produce a funnel.
- If later opt-in events are added, restrict them to coarse journey-use counts and anonymous build diagnostics. Never include exact prayer times, coordinates, diary text, prayer completion, reasons for a pause, or identifiers from external religious groups.
- Joining a religious community or seeing an ad is not consent to profile someone. Keep recruitment contact details separate from product-use data and delete research contact data after its agreed retention period.
- Attribution may be incomplete without invasive cross-app tracking. Preserve “unknown” instead of inventing exact source-to-purchase linkage.

## 9. Monetization sequence

**Beta and core utility: free and ad-free.** The 14-step starter, prayer times, Qibla, basic reminders/widget and local notes stay free. No paywall appears when the user is trying to view a prayer time or return after a gap.

**First paid experiment:** one complete additional reviewed journey, initially testing **$7.99 one-time**. Charge only when it exists and is ready to use. Clearly state exactly which journey is purchased and supported; do not sell a vague lifetime promise for all future content.

**Subscription hypothesis:** **$5.99/month or $39.99/year**, available only after at least three complete paid journeys and a credible funded plan for ongoing additions/support. Candidate topics: daily Qur'an engagement, patience in everyday situations, and sustaining a routine through change. Show available content before purchase. No countdown or founder discount is needed at launch.

If both a subscription and one-time purchases are eventually offered, explain overlapping access and restore purchases. An owned journey remains owned after a subscription expires. Do not ship both billing models at once just to run an early pricing test.

Purchase acceptance criteria: correct localized price and term; explicit recurring status where applicable; purchase success/failure/cancellation; restored entitlement on reinstall; offline access consistent with ownership; refund/revocation handling; manage-subscription route; free features remain usable. Use Apple's in-app purchase route for the initial ordinary App Store digital-content model and verify storefront-specific rules before submission. [Apple in-app purchase guidelines](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase)

Illustration, not forecast: 100 annual subscribers at $39.99 produce $3,999 gross annual billings, or approximately $3,399 after a 15% commission alone. That excludes taxes, refunds, content, support and every operating cost. The 15% rate requires qualifying for and enrolling in Apple's Small Business Program, including associated-account rules. [Apple Small Business Program](https://developer.apple.com/app-store/small-business-program/)

Do not begin with ads, selling sensitive data, paid streak repairs, or commissions on charitable contributions. Family subscriptions and organization sponsorship can wait until individual retention is demonstrated.

## 10. Measurement and decision gates

All thresholds below are proposed internal decision rules. They are not market benchmarks, forecasts, clinical measures, or measures of religious observance. Report raw counts with percentages and separate founder-assisted pilots from unassisted app use.

| Metric | Exact definition | Initial decision rule |
|---|---|---|
| Starter | Consented adult participant given access | Report how many start from each approved recruitment source |
| Activated | Opens first teaching and chooses first action within 48 hours of access | Reach at least 20 activated users before interpreting retention; report starters-to-activation separately |
| D7 journey return | Activated users with journey engagement on at least one of local days 6–8, divided by activated users whose full window elapsed | At least 40%, e.g. 8/20 |
| D14 journey return | Same rule for local days 13–15 | At least 25%, e.g. 5/20 |
| Journey completion | Activated users who finish 14 lesson steps by day 21, divided by eligible activated users | Report separately; never equate D14 return with completion |
| Perceived practical value | Voluntary concrete account of something useful outside the app | Seek at least five specific examples without soliciting private worship records |
| Paid validation | Actual purchasers divided by eligible activated users who saw a real, available offer | Seek at least five purchases from at least 30 exposed eligible users; directional evidence only |
| Trust and correctness | Unresolved serious source, prayer-time, privacy or data-loss defects | Zero known unresolved serious defects before public launch |

Day 0 is the activation date in the participant's chosen local zone. “Journey engagement” means opening a teaching and choosing an action or taking an explicit reflection step; an app launch, prayer-clock check or notification impression alone does not qualify. Count people once per measurement window. For manual feedback, show responders and unknowns; do not silently classify missing responses as observed engagement. The conservative pilot gate uses confirmed returns over the full eligible cohort.

If users return only for free utility, investigate whether the paid journey has a real job. If they consistently prefer a current competitor, change the cohort/problem or stop. If people like the content but resist recurring payment, retain the one-time model. Do not scale acquisition merely because downloads increased.

## 11. Roadmap, owners, and release gates

Planning assumption: one experienced founder builds and supports the app, with a consenting reviewer. These are effort ranges after scope validation, not promised release dates.

1. **Weeks 1–2:** founder interviews, name test, competitor comparison, reviewer/rights check, prototype.
2. **Weeks 3–5:** concierge journey plus full day-15 observation window; revise from failures. Marketing stays within permitted communities.
3. **After the pilot gate:** approximately 4–6 focused founder development weeks for the narrow native beta, plus review and testing. Part-time work, unavailable reviewers or unfamiliar iOS work extends this.
4. **After a stable beta:** free public launch and Product Hunt preparation. Public launch is gated by readiness, not a fixed week in the marketing calendar.
5. **After repeat use:** finish one paid journey and test actual purchases. Subscription and paid acquisition remain later decisions.

Founder owns product, code, support, consent and budget decisions. Reviewer owns the accuracy/appropriateness of the agreed content scope. Testers provide evidence, not blanket certification. No role is assumed to be recruited yet.

Release checklist:

- [ ] Name screened and chosen; no assertion that brainstorm results confer trademark rights.
- [ ] All shipped content and third-party assets have documented rights and review.
- [ ] Prayer/Qibla test matrix and real-device reminder tests pass.
- [ ] Seven-day reminder horizon and travel limitations are visible and understandable.
- [ ] Offline flow, data migration, export/delete and accessibility pass.
- [ ] Privacy claims match observed network/data behavior and store disclosures.
- [ ] Support contact, privacy notice, terms and correction process exist.
- [ ] Membership and any purchases are separately authorized; billing is tested if enabled.
- [ ] Listing/screenshots describe available features; beta status is honest.
- [ ] Relevant platform/community rules are rechecked before marketing publication.

Open decisions: final name; first reachable community and storefronts; supported calculation conventions; reviewer and translation rights; existing Apple membership; available founder hours. Resolve them during validation. They do not require expanding the product before learning whether the first routine is useful.
