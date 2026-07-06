# DealDash — End-to-End Test Runbook

Last updated: 2026-07-06

A staged process to exercise the whole system, catch errors, and surface improvement
zones. Work top to bottom — each stage assumes the previous one passed. For every step
there's an **Expected** result and **🚩 Red flags** to watch for.

---

## Stage 0 — Prerequisites & credentials

You need these keys before anything talks to a live service:

| Key | Where it goes | Used by |
|---|---|---|
| `SUPABASE_URL` | mobile `.env`, admin `.env.local`, scraper `.env` | all |
| `SUPABASE_ANON_KEY` | mobile `.env` | Flutter app (client, RLS-scoped) |
| `SUPABASE_SERVICE_ROLE_KEY` | admin `.env.local`, scraper `.env` | admin + scraper (bypass RLS) |
| `ANTHROPIC_API_KEY` | scraper `.env` | Claude normaliser |
| `FIRECRAWL_API_KEY` | scraper `.env` | HTML fetch |
| `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_ID_MONTHLY` | Supabase Edge Function secrets | Stripe functions |
| Firebase service account (`FIREBASE_*`) | Edge Function secrets | FCM push |

Copy each `.env.example` to `.env` / `.env.local` and fill in. **Never commit these**
(they're gitignored).

🚩 If any app boots with `undefined` env values, it fails silently or crashes on first
call — check `.env` is loaded before testing further.

---

## Stage 1 — Database sanity

Confirm the schema and seed data are in place (migrations 001–007 were applied).

In the Supabase SQL editor:

```sql
select count(*) from retailers;        -- expect 15
select count(*) from categories;       -- expect 8 (+ subcategories)
select count(*) from products;         -- expect ~20 seed products
select count(*) from price_history;    -- expect 0 until the scraper runs
-- RLS must be ON for user tables:
select relname, relrowsecurity from pg_class
  where relname in ('users','watchlist','notifications','user_preferences');
```

Run the admin seed if you haven't: `supabase/migrations/006_admin_seed.sql`
(creates `admin@dealdash.com.au` / `admin123`).

**Expected:** 15 retailers, 8 categories, ~20 products, `relrowsecurity = t` on all user
tables.
🚩 `relrowsecurity = f` on any user table = a data-leak risk; re-run `002_rls_policies.sql`.

---

## Stage 2 — Scraper (the data engine)

This is the highest-value test: it exercises Firecrawl + Claude + the DB writer in one shot.

```bash
cd packages/scraper
npm install
npm run build      # must be exit 0
npm run scrape     # one-off Woolworths run
```

Watch the pino logs for a line like:
`Scrape completed { slug: 'woolworths', found: N, inserted: N, updated: N, errors: N }`

Then verify data landed:

```sql
select * from scrape_logs order by started_at desc limit 1;   -- status = 'success'/'partial'
select count(*) from price_history where is_active = true;    -- > 0
select * from public.get_today_deals(10);                     -- ranked deals
```

**Expected:** a `scrape_logs` row with a non-zero `products_found`, active `price_history`
rows, and `get_today_deals` returning ranked results.
🚩 `Empty HTML from Firecrawl` (bad key / JS-gated page), `Claude returned invalid JSON`
(check the logged 200-char preview), or `found > 0` but `inserted = 0` (retailer slug
mismatch, or validation dropping everything). See `SCRAPER.md` → Troubleshooting.

> **Cost note:** each scrape call hits `claude-sonnet-5`. One `--once` run is cheap; don't
> loop the full 15-retailer batch repeatedly while debugging.

---

## Stage 3 — Edge Functions

Deploy and smoke-test the functions:

```bash
supabase functions deploy   # deploys all 7
```

**Freemium gate** (core monetisation logic) — call it 11 times for a free user:

```bash
curl -s -X POST "$SUPABASE_URL/functions/v1/check-freemium-gate" \
  -H "Authorization: Bearer <a user access token>" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"<user uuid>"}'
```

**Expected:** calls 1–10 return `{allowed:true, remaining:N}` with `remaining` counting
down; call 11 returns `{allowed:false, show_paywall:true}`. A premium user always gets
`{allowed:true, remaining:null}`.
🚩 `remaining` not decrementing → `increment_search_count` / `search_logs` write failing.

**Deal ranking:** invoke `daily-deal-rank`, then `select * from deal_cache order by
ranked_at desc limit 1;` — should hold a JSON array of ranked deals.

---

## Stage 4 — Flutter app (user flow)

```bash
cd apps/mobile
flutter pub get
flutter analyze          # expect: No issues found!
flutter run -d chrome    # fastest; or a device/emulator
```

Walk the full journey and confirm each screen renders **loading → data → error** states:

1. **Splash** → routes to onboarding (new) or home (logged in).
2. **Register** → new account; check a `users` + `user_preferences` row appears
   (the `handle_new_user` trigger).
3. **Onboarding** → select stores + categories → saved to
   `user_preferences.favourite_*_ids`.
4. **Home** → "Today's Best Deals" / "Trending" / "Ending Soon" populate from
   `get_today_deals` (needs Stage 2 data). Pull-to-refresh works.
5. **Search** → type a query → debounced results from `search_products`; run 11 searches
   to hit the paywall.
6. **Product detail** → price comparison table + price history chart + add/remove
   watchlist.
7. **Watchlist** → item appears; swipe to remove.
8. **Profile** → notification toggles persist to `user_preferences`; logout works.

**Expected:** no red error screens; every list has a real empty-state (not a blank
screen); prices show `AUD` + 2 decimals.
🚩 Blank home = no scraped data (do Stage 2 first). Overflow/render errors in the console.
Missing loading shimmers. Search that never debounces (fires per keystroke).

---

## Stage 5 — Admin portal

```bash
cd apps/admin
npm install
npm run dev              # http://localhost:3001
npm run build            # also confirm the production build (expect exit 0)
```

Log in (`admin@dealdash.com.au` / `admin123`) and check each page:

- **Dashboard** — stats cards + revenue chart + scrape-health table populate.
- **Retailers** — 15 rows; toggle active; "trigger manual scrape".
- **Products / Promotions** — populated after Stage 2.
- **Users** — your test accounts appear.
- **Notifications** — send a manual notification (needs FCM configured).
- **System Health** — scrape logs + Claude token usage.

**Expected:** every page loads with real data, no 500s.
🚩 A page stuck loading or throwing = a missing service-role key or a query referencing a
column that doesn't exist.

---

## Stage 6 — Paid + push integrations (test mode)

- **Stripe** (test keys): tap the paywall → hosted Checkout → pay with `4242 4242 4242
  4242` → confirm `stripe-webhook` flips `users.subscription_status` to `premium` and adds
  a `subscriptions` row.
- **FCM**: put a product on a watchlist, run the scraper so its price drops, and confirm
  `on-price-insert` sends a push and logs a `notifications` row. Tap it → deep-links to the
  product.

🚩 Webhook not firing = signature secret mismatch or the endpoint URL isn't registered in
Stripe. No push = Firebase service-account env vars missing or the device `fcm_token`
never saved.

---

## Improvement zones to evaluate (what to grade once it runs)

Areas most likely to need iteration — worth judging deliberately, not just "does it work":

1. **Scraper reliability** — Firecrawl on JS-heavy retailers (Coles, Kmart, JB Hi-Fi) may
   return thin HTML. Track per-retailer success in `scrape_logs`; some sites may need a
   longer `waitFor` or a different specials URL.
2. **Claude extraction accuracy** — spot-check `products` vs. the live retailer page for
   wrong prices, duplicates, or miscategorised items. If a retailer is consistently bad,
   consider bumping that call to a stronger model or tightening the system prompt.
3. **Product de-duplication** — the same item from different retailers should collapse to
   one `products` row. Without barcodes, matching is by name; check for near-duplicates.
4. **Search quality** — full-text ranking relevance; typo tolerance; empty-result UX.
5. **Freemium calibration** — is 10 lifetime searches the right wall? Instrument
   conversion at the paywall.
6. **Notification volume** — `max_notifications_per_day` and relevance; avoid spammy
   drops on trivial discounts.
7. **Empty/first-run states** — before the scraper has data, the app should guide the user,
   not show blank lists.
8. **Cost** — Claude + Firecrawl spend per nightly batch; watch the System Health token
   counter as retailer count grows.
9. **Performance** — home/list scroll with cached images; `get_today_deals` query time as
   `price_history` grows (indexes exist, but verify with `explain analyze` at scale).
10. **Security** — re-confirm RLS on every user table, Stripe signature verification, and
    that no service-role key reaches the client bundle.

---

## Quick-reference commands

```bash
# Scraper
cd packages/scraper && npm run build && npm run scrape

# Flutter
cd apps/mobile && flutter analyze && flutter run -d chrome

# Admin
cd apps/admin && npm run dev            # localhost:3001

# Edge functions
supabase functions deploy
```
