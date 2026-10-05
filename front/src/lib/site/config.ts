const release = import.meta.env.SALAH_SIDE_SITE_RELEASE === '1';
const supportEmail = (import.meta.env.PUBLIC_SUPPORT_EMAIL || '').trim();
const publisher = (import.meta.env.PUBLIC_PUBLISHER_NAME || '').trim();
const siteURL = (import.meta.env.PUBLIC_SITE_URL || '').trim();
const appStoreURL = (import.meta.env.PUBLIC_APP_STORE_URL || '').trim();
const effectiveDate = (import.meta.env.PUBLIC_POLICY_EFFECTIVE_DATE || '').trim();

function validHTTPSOrigin(value: string): boolean {
  try {
    const url = new URL(value);
    return (
      url.protocol === 'https:' &&
      url.pathname === '/' &&
      !url.search &&
      !url.hash &&
      !url.username &&
      !url.password &&
      !['localhost', 'example.com', 'example.org'].includes(url.hostname) &&
      !['.example', '.test', '.invalid', '.local'].some((suffix) => url.hostname.endsWith(suffix))
    );
  } catch {
    return false;
  }
}

if (release) {
  const missing: string[] = [];
  if (!validHTTPSOrigin(siteURL)) missing.push('PUBLIC_SITE_URL (real HTTPS origin)');
  if (!publisher || publisher.includes('[')) missing.push('PUBLIC_PUBLISHER_NAME');
  if (!/^[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+$/.test(supportEmail)) missing.push('PUBLIC_SUPPORT_EMAIL');
  if (
    !/^\d{4}-\d{2}-\d{2}$/.test(effectiveDate) ||
    Number.isNaN(Date.parse(effectiveDate)) ||
    new Date(effectiveDate).toISOString().slice(0, 10) !== effectiveDate
  )
    missing.push('PUBLIC_POLICY_EFFECTIVE_DATE (YYYY-MM-DD)');
  if (missing.length) throw new Error(`SalahSide publication requires: ${missing.join(', ')}.`);
}
if (
  appStoreURL &&
  !/^https:\/\/apps\.apple\.com\/(?:[a-z]{2}\/)?app\/[^?#]+\/id\d+$/.test(appStoreURL)
) {
  throw new Error('PUBLIC_APP_STORE_URL must be the actual apps.apple.com listing URL.');
}
export const site = { release, supportEmail, publisher, siteURL, appStoreURL, effectiveDate };
