import { site } from '../lib/site/config';
export const prerender = true;
export function GET() {
  return new Response(
    site.release
      ? `User-agent: *\nAllow: /\nSitemap: ${new URL('/sitemap-index.xml', site.siteURL).href}\n`
      : 'User-agent: *\nDisallow: /\n',
    { headers: { 'Content-Type': 'text/plain; charset=utf-8' } },
  );
}
