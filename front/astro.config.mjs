// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import react from '@astrojs/react';
import tailwindcss from '@tailwindcss/vite';
import { loadEnv } from 'vite';

const env = loadEnv(process.env.NODE_ENV || 'development', process.cwd(), '');
const siteURL = process.env.PUBLIC_SITE_URL || env.PUBLIC_SITE_URL;

// The public SalahSide site is generated HTML and assets; it needs no app server.
export default defineConfig({
  site: siteURL || undefined,
  output: 'static',
  trailingSlash: 'always',
  integrations: [
    ...(siteURL ? [sitemap({ filter: (page) => !page.endsWith('/404/') })] : []),
    react(),
  ],
  devToolbar: { enabled: false },
  vite: { plugins: [tailwindcss()] },
});
