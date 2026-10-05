# SalahSide public website

English landing page, Privacy Policy, Terms, Support, and a custom 404 page. Astro generates static HTML/CSS with optimized local images. FAQ disclosures work without JavaScript. No analytics, account, mailing list, contact form, or remote font service is included.

The Today image is an actual simulator capture. Architecture and icon assets come from the native app artwork. The landing page advertises no unconfirmed prices or trial eligibility and shows Coming soon until an actual App Store listing URL is configured.

## Local development and checks

```sh
bun install --frozen-lockfile
bun run dev
bun run check
bun run lint
bun test
bun run format:check
bun run build
bun run preview
```

Use the URL printed by the server. The review preview used `http://127.0.0.1:4340/` for the built site; a future run may use a different port.

## Publication configuration

Copy `.env.example` to ignored `.env`. Set the real values; business contact details are rendered publicly. No credentials belong in these fields.

| Variable                       | Purpose                                                             |
| ------------------------------ | ------------------------------------------------------------------- |
| `PUBLIC_SITE_URL`              | Real HTTPS origin under the publisher's control, without a path     |
| `PUBLIC_PUBLISHER_NAME`        | Confirmed legal publisher name                                      |
| `PUBLIC_SUPPORT_EMAIL`         | Working support and privacy contact mailbox                         |
| `PUBLIC_POLICY_EFFECTIVE_DATE` | Actual publication date, YYYY-MM-DD                                 |
| `PUBLIC_APP_STORE_URL`         | Optional real `apps.apple.com` listing; leave blank until available |
| `SALAH_SIDE_SITE_RELEASE`      | `0` for drafts; `1` requires the four publication fields            |

Preview builds are marked noindex and disallow crawling. Legal pages label themselves as publication drafts. With release mode enabled, missing publication fields fail the build; configured fields produce canonical URLs, a sitemap, and dated publisher/contact copy. Syntax checks do not prove domain ownership, mailbox delivery, legal identity, or public policy accessibility. Confirm these before publishing.

```sh
SALAH_SIDE_SITE_RELEASE=1 bun run build
```

`dist/` is published as static assets from the `salahside` Cloudflare Worker. `bun run deploy` builds the site and publishes it to the account's `workers.dev` subdomain using the checked-in Wrangler configuration; the custom domain can be attached to the Worker later. The default preview stays `noindex`, disallows crawling, and labels the legal pages as drafts until the real domain, publisher, support email, and policy effective date are configured. For a release publication, set those fields with `SALAH_SIDE_SITE_RELEASE=1`, then deploy again. See [Cloudflare Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/) and [Astro's Cloudflare guide](https://docs.astro.build/en/guides/deploy/cloudflare/).

After publishing, verify `/privacy/`, `/terms/`, and `/support/` over HTTPS without login. Set the same public policy URL in native `Release.local.xcconfig` and the policy/support URLs in App Store Connect. Validate the mailbox and hosting/email data practices described in the policy.

## Design and evidence

The [three section concepts](../docs/release/site-concepts/) were generated with built-in image_gen. Full prompts and the revision are in [prompts.json](../docs/release/site-concepts/prompts.json). [Site QA](../docs/release/site-qa.md) records browser/build evidence and comparisons. Original app images are retained; the device frame and architectural clipping are code.
