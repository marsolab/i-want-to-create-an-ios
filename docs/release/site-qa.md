# SalahSide website QA — October 5, 2026

Local review only. No domain was purchased, website published, or App Store listing created. Publisher, support mailbox, and public HTTPS origin remain owner inputs.

## Sources and method

Built-in image_gen produced [hero](site-concepts/hero.png), [journey](site-concepts/journey.png), and [privacy/membership/FAQ](site-concepts/details.png) concepts. Complete prompts are in [prompts.json](site-concepts/prompts.json). These section references were the implementation spec in the existing Astro project; no separate user design-approval step was requested. The legal/support pages extend the same typography, palette, navigation, disclosure, and rule components.

Used Codex's in-app browser through cua_repl, including its documented Playwright locators and viewport capability. Verified the development site and the built static site at the actual server URLs. Initial attempts at port 4321 were blocked; the server had selected 4326, and the built-site preview used 4340. No browser fallback was needed.

Captured the implementation at the concepts' native 1505 × 1045 size and checked it with view_image alongside the concepts. Also inspected the latest mobile screenshot with view_image. Browser screenshots are saved in [screenshots](screenshots/). The temporary viewport override was reset at handoff.

## Visual comparison ledger

| Comparison                 | Reference                                                                         | Implementation and resolution                                                                                                                       |
| -------------------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| First viewport composition | Hero: wordmark/nav, two-line headline, left CTA, right phone, lower feature strip | Matched two-column layout and first viewport feature preview; corrected heading width/size and phone placement.                                     |
| Typography                 | Serif editorial headings, quiet sans-serif navigation/body                        | Georgia/Arial local font stack, explicit heading/body/control sizes; enlarged initial small supporting text and restored two-line desktop headline. |
| Palette and media          | Warm ivory, forest/sage, untinted architecture                                    | Locked tokens #f8f5ef/#183b32/#426b55; no image color overlay or invented gradient.                                                                 |
| CTA and visible copy       | Explore SalahSide, Coming soon to the App Store, three nav links                  | Corrected button dimensions/alignment; exact hero/nav/feature copy preserved. No unconfirmed pricing or listing URL.                                |
| Journey                    | Single architectural image and three numbered ruled rows                          | Preserved row structure/copy; corrected pointed arch clipping and text hierarchy.                                                                   |
| Privacy/membership/FAQ     | Two open text columns, four disclosure rows, simple legal footer                  | Preserved section order and copy. Rejected the initial generated variant that omitted membership and inserted duplicate pictures.                   |
| Responsive behavior        | Same components continue on small screens                                         | Hero stacks by tablet width; 320/390/768/1024px have no horizontal overflow and images load. Legal/support pages also passed at 320px.              |
| Controls and motion        | Restrained arrow/chevron, working navigation and disclosures                      | SVG arrow/chevrons; native details/summary, focus outlines and skip link; reduced-motion CSS removes transitions and smooth scrolling.              |

The design was faithfully verified against the section references for the listed elements. Two intentional asset adaptations remain: the actual simulator screenshot replaces the image-generated phone screen, and the outer device frame is simplified CSS rather than generated hardware. Original approved architecture imagery is retained instead of the model's small image reinterpretations. These keep product imagery authentic. No fixable content clipping, missing image, or inert control remains in the checked views.

Above-the-fold copy diff: matched wordmark, three nav labels, two headline sentences, supporting sentence, CTA, availability sentence, and the feature strip. Line wrapping and semantic heading elements do not add visible claims.

## Functional and artifact evidence

- CTA reached #how-it-works. Header Privacy and Support links opened their corresponding pages. All five built pages have one H1; internal links and local assets exist.
- Membership FAQ opened with a click and disclosed renewal/trial terms. Restore-subscription support disclosure opened with Enter. All disclosures use native HTML, including collapse behavior.
- Built homepage contains zero script tags; no contact form is shipped. Optimized local WebP images loaded. Browser error log was empty in the final built-site check.
- `bun install --frozen-lockfile`, `bun run build`, `bun run check`, `bun run lint`, `bun test`, and `bun run format:check` passed. Existing utility suite: 3 tests, 0 failures. Astro check: 75 files, 0 errors, 0 warnings, one existing chart deprecation hint.
- Release-mode negative check failed as expected with all four missing owner fields named. Evidence: `/private/tmp/salahside-site-release-guard.log`. Preview robots and meta tags disallow indexing. A release-mode build with actual owner values is pending.
- Fixed pre-existing lockfile conflict markers and the template's incompatible Vite override. Astro 7 requires Vite 8. TypeScript 7 lacks the classic API needed by the installed Astro checker, whose declared peer range is TypeScript 5 or 6; the project uses compatible 5.9.3. See [Astro 7 migration](https://docs.astro.build/en/guides/upgrade-to/v7/) and [TypeScript compiler API](https://github.com/microsoft/TypeScript/wiki/Using-the-Compiler-API).

## Before public release

Confirm publisher identity, working support mailbox, actual public origin and policy date. Verify hosting/email data practices against the privacy text. Publish the concrete site, verify all legal/support URLs without login, then use those URLs in the native configuration and App Store Connect. App Store release still needs the signing team, Family Controls approval, live subscription configuration and physical-device acceptance documented in [release preparation](README.md).

## Impeccable polish — October 5, 2026

Scoped refinement of the incumbent website: the landing page remains a Persuade surface; support and legal pages remain Read surfaces. Preserved the Georgia/Arial typography, ivory/forest palette, existing artwork, factual product copy, routes, native disclosures and publication configuration. No formal PRODUCT.md or DESIGN.md exists; the implementation and section references supplied the visual context.

- Smoothed container gutters, hero columns, phone sizing and display type across intermediate widths. Converted fixed text sizes to rem, balanced headings, and kept supporting copy from ending on a single short word.
- Reduced legal/support body measure from 860px to 72ch (approximately 721px at the checked desktop size), with 31.5px line height instead of 27px. Improved section spacing, separated the support contact from request instructions, and spaced the final support paragraph after disclosures.
- Added consistent current-page footer navigation, hover cues, themed selection/scrollbars, and a restrained CTA arrow response. Existing reduced-motion rules disable these transitions.
- Corrected incomplete publisher/email sentence composition in preview mode without inventing contact details or changing legal/product claims.
- The first browser inspection found that Skip to content left focus on BODY, and step numbers had 3.90:1 contrast. The final correction makes MAIN programmatically focusable; Enter focuses MAIN and the following Tab reaches Explore SalahSide with a visible outline. Step numbers now use the shared quiet text color with contrast above 4.5:1.

Verification was bounded to one inspection round, one correction batch and one confirmation round. The built site was checked in Codex's in-app browser at 1280px desktop, 390px mobile, and 320/768/1024px intermediate widths. No horizontal overflow was observed; Privacy and Terms also fit at 320px. The membership/restore disclosures opened with Enter, both images loaded, footer current-page state was correct, and the browser error log was empty. The homepage still contains zero scripts. No actual browser text-zoom or Safari session was captured.

The single requested mechanical detector scan returned no findings. Final build, Astro check (0 errors/warnings; one pre-existing chart deprecation hint), lint, formatting and source whitespace checks passed. The existing three utility tests also passed; they are not visual test coverage. No publication or native distribution action was performed by this refinement.

Final captures: [desktop](screenshots/website-polish-desktop.png), [mobile](screenshots/website-polish-mobile.png), and [privacy reading layout](screenshots/website-polish-privacy.png).
