# Membership paywall design QA

Selected visual: `qa-evidence/paywall-selected-paid.png`, 853 × 1844 pixels. Variant 1 was selected with no free tier or trial. Later user instructions override the source pricing: annual displays $2.99/month, with the actual $35.88 yearly charge below Subscribe; monthly remains $3.99/month.

Current native screenshots:

- `qa-evidence/paywall-sheet-blur-fade-annual.png`
- `qa-evidence/paywall-sheet-blur-fade-monthly.png`
- `qa-evidence/paywall-sheet-blur-fade-after-swipe.png`

All three were captured by passing XCTest UI tests on iPhone 18 Pro, iOS 27, light mode, at 1206 × 2622 pixels (402 × 874 points at 3× density).

## Final presentation

The paywall slides up in a large native sheet with rounded top corners. There is no close control or drag indicator. Interactive dismissal is disabled until StoreKit reports a verified active subscription. A verified purchase or restoration dismisses the sheet and opens Today; pending, cancelled, unavailable and failed purchases do not grant access.

The presenting photo fills the top safe area and receives a 20-point blur while the paywall is open. Default sheet dimming is removed to avoid the rejected grey status-bar strip. The presenting introduction is excluded from touch and accessibility interaction. The sheet photo, system indicators and paywall controls remain sharp.

A native gradient, up to 96 points tall, fades the cropped bottom of the photo into the exact ivory canvas color. The selected mosque raster remains intact. The pointed arch, mosque, palms and sky remain visible; the prayer rug softens into the heading background.

## Visual verification

- Native sans-serif typography: 42-point two-line headline, 15-point supporting text, 18-point prices and 12.5-point billing disclosure.
- Layout: 24-point content margins, 52-point plan rows, 56-point primary action. Plans, Subscribe, disclosure and footer fit without scrolling at the tested default text size.
- Identity: warm ivory, muted sage, deep ink and the selected arch-and-mosque image.
- Content: annual and monthly amounts and renewal disclosures match the selected plan; VoiceOver includes both the monthly equivalent and actual billed amount.
- Interaction: full-row plan selection works; a downward dismissal gesture leaves the paywall open; Privacy opens and returns to the paywall.

Inspected all three captures. The blurred status-bar background and gradual image-to-canvas transition resolve the two reported edges. No actionable P0/P1/P2 visual findings remain at the tested viewport.

## Validation

- The isolated PR checkout passed all 6 state tests and 3 UI tests after XcodeGen regeneration and formatting: 9 passed, 0 failed, 0 skipped; 47.3 seconds. Build/test diagnostics contain no warnings or errors.
- Swift formatting and lint use the included four-space configuration.
- The entitlement-driven transition was reviewed in code; a successful sandbox purchase was not performed.

## Remaining release validation

- Configure the subscription products and supported App Store prices; test purchase, cancellation, pending purchase, restoration, revocation and expiration in StoreKit sandbox.
- Validate scheduled Screen Time shielding on a physical iPhone with the necessary entitlement and extensions. The current UI identifies this platform boundary.
- Provide a published privacy-policy URL.
- Larger accessibility text sizes can scroll but have not received visual validation in this pass.
- Exact mosque focal scale and footer styling remain optional P3 refinements.

Final visual result: passed at the tested viewport.
