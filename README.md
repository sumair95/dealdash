# DealDash Australia

AI-powered mobile shopping app for Australian retailer deals, with Supabase backend, Flutter mobile client, scraping service, and admin portal.

## Monorepo Layout

- `apps/mobile` - Flutter application
- `apps/admin` - Next.js admin portal
- `packages/scraper` - Node.js scraping and normalisation service
- `supabase` - SQL migrations and edge functions
- `docs` - setup and architecture docs

## Quick Start

1. Copy `.env.example` values into local env files.
2. Run Supabase migrations.
3. Start app-specific dev servers from each package.

Detailed setup instructions will be available in `docs/SETUP.md`.
