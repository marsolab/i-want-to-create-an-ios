# Setup before the three-day trial

The October 4 user requirement supersedes the earlier no-trial decision: users configure the app before seeing the paywall, then confirm a three-day free trial followed by monthly or yearly subscription billing.

## Flow and scope

Reuse the native settings form for first-run setup. City and calculation method must be selected before continuing; Screen Time permission and app selection remain optional. All five prayer switches default on. Save the schedule choices, notification preference, prayer switches, opaque Family Controls selection and setup completion on device.

After Continue, show the existing locked membership sheet. Cancelling, pending payment, unavailable products and a dismissed review/settings sheet retain setup but do not grant access. Review your setup remains available inside the paywall. Verified subscribers, including active trials, see Today; expired subscribers return to the membership sheet with their configuration preserved.

Keep the existing native slice's limits: schedule selections remain placeholders, and notification delivery and physical-device scheduled shielding are separate implementation/validation gates. This change does not claim those services are complete.

## StoreKit and disclosure

Monthly and yearly are auto-renewable products in one group, each with an introductory free offer lasting three days. The trial starts after Apple confirms purchase. Apple handles the subsequent charge and renewals; do not create a local trial timer or separate charge operation.

Show trial copy only when product metadata describes exactly three free days and StoreKit confirms account eligibility. Ineligible accounts receive normal upfront billing copy. Missing products do not grant access. An unsupported eligible introductory offer must not be purchased under misleading disclosure. Recheck eligibility before purchase and ask the user to review if the displayed offer changes.

Keep yearly selected initially. Emphasize the full yearly price, with its monthly equivalent secondary when numeric and localized price metadata agree. Hide optional computed prices/value comparisons if metadata disagree. Match the selected plan's full post-trial charge in the disclosure and expose automatic renewal, Restore, Terms and Privacy.

## Validation

Use Apple's local StoreKit configuration with both trial products; include it only in test bundles. Verify metadata and prices, three-day trial duration, purchase/restore access, pending and cancelled purchases, expiration, and group-wide trial ineligibility. Exercise first-run ordering, setup persistence, plan-switch disclosure and locked swipe dismissal in native UI tests. Record simulator evidence separately from App Store Connect and sandbox validation.
