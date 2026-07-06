# DealDash Australia — Architecture

Last updated: 2026-07-06

DealDash aggregates promotional pricing from 15 Australian retailers, normalises it
with the Claude API, stores it in Supabase (PostgreSQL), and delivers personalised
price-drop push notifications to a Flutter app via Firebase Cloud Messaging.

## System overview

```
                          ┌──────────────────────────────┐
                          │  Scraper service (Railway)    │
                          │  packages/scraper — Node/TS   │
   Retailer websites ───▶ │  Firecrawl → Claude normalise │
   (15 catalogues)        │  → validate → upsert          │
                          └───────────────┬───────────────┘
                                          │ service-role writes
                                          ▼
   ┌───────────────────────────────────────────────────────────────┐
   │                    Supabase (PostgreSQL)                        │
   │  tables: retailers, products, retailer_products, price_history, │
   │          users, user_preferences, watchlist, notifications,     │
   │          search_logs, subscriptions, scrape_logs, deal_cache    │
   │  RPC: get_today_deals, search_products, increment_search_count  │
   │  Edge Functions (Deno): freemium gate, Stripe, notifications,   │
   │          deal ranking, cleanup                                  │
   └───────┬───────────────────────────────┬───────────────┬────────┘
           │ anon key + RLS                │ service role  │ Stripe/FCM
           ▼                               ▼               ▼
   ┌───────────────┐              ┌─────────────────┐  ┌──────────┐
   │ Flutter app   │              │ Next.js admin   │  │ FCM /    │
   │ apps/mobile   │              │ apps/admin      │  │ Stripe   │
   │ Riverpod +    │              │ (Vercel)        │  │ webhooks │
   │ GoRouter      │              └─────────────────┘  └──────────┘
   └───────────────┘
```

## Components

| Component | Path | Runtime | Hosting |
|---|---|---|---|
| Mobile app | `apps/mobile` | Flutter / Dart 3 | iOS + Android |
| Admin portal | `apps/admin` | Next.js 14 App Router | Vercel |
| Scraper service | `packages/scraper` | Node.js 20 / TypeScript | Railway |
| Database + auth | `supabase/` | PostgreSQL + Deno Edge Functions | Supabase |

## Data flow — daily scrape cycle

1. **Cron trigger** (`packages/scraper/src/index.ts`). Three schedules (UTC):
   - `0 16 * * *` — 12 daily retailers, concurrency 3 (2 AM AEST).
   - `0 18 * * 2,5` — Aldi Special Buys (Tue/Fri).
   - `0 20 * * 0` — Costco + IKEA (weekly, Sunday).
2. **Scrape** — each retailer is a `BaseScraper` built by `createRetailerScraper(slug, url)`.
   `fetchWithFirecrawl()` retrieves clean HTML.
3. **Normalise** — `normaliseWithClaude()` sends up to a 50K-char HTML chunk to
   `claude-sonnet-5` (thinking disabled) and gets back a JSON array of promotional
   products against a fixed schema.
4. **Validate** — `BaseScraper.validateProduct()` drops rows where `sale_price >=
   regular_price` or the discount is outside 1–99%.
5. **Persist** — `upsertProductsFromScrape()` upserts `products` + `retailer_products`,
   flips prior `price_history` rows to `is_active = false`, and inserts the new price
   rows. A `scrape_logs` row records found/inserted/updated/errors.
6. **Notify** — the scraper POSTs the new `price_history` IDs to the `on-price-insert`
   Edge Function, which matches watchlists and sends FCM notifications.

## Notification delivery flow

```
scraper → on-price-insert edge fn → match watchlist rows with notifications enabled
        → generate copy → FCM send → insert notifications row (log)
        → device receives → tap → deep-link to /product/:id
```

## Subscription flow

```
Flutter paywall → stripe-create-checkout edge fn → Stripe Checkout (hosted)
   → user pays → Stripe → stripe-webhook edge fn
   → update users.subscription_status + subscriptions table
Freemium gate: every search → check-freemium-gate edge fn
   (premium → unlimited; free → 10 lifetime, then paywall)
```

## Trust boundaries

- **Flutter app** uses the Supabase **anon key**; all user-table access is governed by
  Row Level Security (`auth.uid() = user_id`). Public read on products/retailers/
  categories/price_history.
- **Scraper** and **admin** use the **service-role key** (never shipped to clients) and
  bypass RLS for bulk writes and admin reads.
- **Stripe webhook** verifies the `Stripe-Signature` header; no JWT.
- **Admin portal** authenticates admins separately (`admin_users` table) via its own
  session cookie + middleware.

See `SCRAPER.md` for scraper internals and `API.md` for the endpoint contracts.
