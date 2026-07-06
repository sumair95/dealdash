# DealDash — API Reference

Last updated: 2026-07-06

Three surfaces back the app: Supabase **RPC functions** (Postgres, called via the
client SDK), Supabase **Edge Functions** (Deno HTTP endpoints), and the admin portal's
own **Next.js API routes**. All Supabase access from the mobile app uses the anon key
and is subject to Row Level Security.

## Supabase RPC functions

Called from Flutter via `supabase.rpc(...)` (see `apps/mobile/lib/core/services/supabase_service.dart`).

### `get_today_deals(p_limit int default 50)`
Returns the best active deals from the last 24 hours, ranked by `discount_pct`.
Columns: `product_id, product_name, brand, image_url, retailer_id, retailer_name,
retailer_logo, regular_price, sale_price, discount_pct, promotion_type,
promotion_ends_at, product_url`.

### `search_products(p_query, p_category_id, p_retailer_id, p_min_discount, p_max_price, p_limit, p_offset)`
Full-text product search over active promotions. All filters are nullable.
Returns: `product_id, product_name, brand, image_url, best_price, best_retailer_name,
best_discount_pct, retailer_count`.

### `increment_search_count(p_user_id uuid)`
Increments `users.search_count` (used by the freemium gate).

> `handle_new_user()` is a trigger, not a callable RPC — it fires on `auth.users` insert
> and creates the matching `public.users` + `user_preferences` rows.

## Edge Functions

Base URL: `https://<project>.supabase.co/functions/v1/<name>`. All validate the caller's
JWT except `stripe-webhook` (which verifies the Stripe signature instead).

| Function | Auth | Request | Response |
|---|---|---|---|
| `check-freemium-gate` | user JWT | `{ user_id }` | `{ allowed, remaining, show_paywall? }` — premium → `allowed:true, remaining:null`; free < 10 → increments + logs; free ≥ 10 → `allowed:false, show_paywall:true` |
| `stripe-create-checkout` | user JWT | `{ user_id, success_url, cancel_url }` | `{ checkout_url }` — creates/reuses Stripe customer + AUD $5/mo subscription Checkout Session |
| `stripe-webhook` | Stripe sig | Stripe event | `200` — handles `customer.subscription.*` + `invoice.payment_*`; updates `users.subscription_status` + `subscriptions` |
| `on-price-insert` | service role | `{ price_history_ids: string[] }` | `200` — matches watchlists, generates copy, sends FCM, logs to `notifications` |
| `daily-deal-rank` | cron | — | ranks `get_today_deals(50)` into `deal_cache` (2:30 AM AEST) |
| `send-manual-notification` | admin JWT | `{ title, body, user_ids? }` | broadcasts FCM to listed users, or all active users |
| `cleanup-expired` | cron | — | sets `price_history.is_active=false` where `promotion_ends_at < now()` (midnight AEST) |

### Example — freemium gate

```http
POST /functions/v1/check-freemium-gate
Authorization: Bearer <user access token>
Content-Type: application/json

{ "user_id": "8a3d…" }
```
```json
{ "allowed": true, "remaining": 7 }
```

## Admin API routes (Next.js, `apps/admin/app/api/`)

| Route | Method | Purpose |
|---|---|---|
| `/api/auth/login` | POST | Authenticate an `admin_users` row; sets the session cookie |
| `/api/notifications/send` | POST | Proxy to `send-manual-notification` for the admin dashboard |

Admin routes are guarded by `apps/admin/middleware.ts`, which checks the session cookie
before serving any protected page or API route.

## Direct table access (RLS)

The mobile app reads/writes tables directly via the Supabase client under RLS:

- **Own-row only** (`auth.uid() = user_id`): `users`, `user_preferences`, `watchlist`,
  `notifications`, `search_logs`, `subscriptions`.
- **Public read**: `products`, `retailers`, `categories`, `retailer_products`,
  `price_history`.

See `ARCHITECTURE.md` for how these fit together and `SCRAPER.md` for how `price_history`
is populated.
