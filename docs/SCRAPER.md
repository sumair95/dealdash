# DealDash — Scraper Service

Last updated: 2026-07-06

Location: `packages/scraper/` — a standalone Node.js/TypeScript service that runs on a
cron schedule (Railway). It fetches each retailer's specials page, extracts promotional
products with the Claude API, validates them, and writes them to Supabase.

## Design

Scrapers are **not** hand-written per retailer. `createRetailerScraper(slug, url)`
(`src/scrapers/retailer-factory.ts`) returns a `BaseScraper` instance, so each retailer
file is a one-liner:

```ts
// src/scrapers/woolworths.ts
import { createRetailerScraper } from "./retailer-factory.js";

export const WoolworthsScraper = createRetailerScraper(
  "woolworths",
  "https://www.woolworths.com.au/shop/catalogue",
);
```

The pipeline for every retailer is identical:

```
fetchWithFirecrawl(url)  →  normaliseWithClaude(html, slug)  →  validateProduct()  →  ScrapeResult
```

- **Firecrawl** (`base-scraper.ts`) returns clean HTML for a URL.
- **Claude** (`ai/claude-normaliser.ts`) extracts a JSON array of promotional products
  from up to a 50K-char chunk, using `claude-sonnet-5` with `thinking: { type: "disabled" }`
  (structured extraction needs no reasoning; disabling keeps the nightly run fast/cheap).
- **Validation** (`base-scraper.ts` → `validateProduct`) rejects rows with a missing name,
  non-positive prices, `sale_price >= regular_price`, or a discount outside 1–99%.

## Model choice

The normaliser and the notification-copy generator both call `claude-sonnet-5`.
Sonnet is the accuracy/cost sweet spot for messy retailer HTML. If cost becomes a
concern, `claude-haiku-4-5` handles the same structured-extraction job at ~⅓ the price;
if extraction quality drops on a particular retailer, that call can be bumped per-site.
Do **not** switch to an omitted `thinking` field on Sonnet 5 — it defaults to adaptive
thinking, which adds latency and token cost this batch job doesn't need.

## Commands

```bash
cd packages/scraper
npm install
npm run build        # tsc — must pass before deploy
npm run scrape       # one-off Woolworths test scrape (node dist/index.js --once)
npm run dev          # start the cron scheduler
```

`--once` runs a single Woolworths scrape end-to-end and writes to Supabase — the fastest
way to confirm credentials and the full pipeline work.

## Required environment (`.env`)

```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_SERVICE_ROLE_KEY=   # service role — bypasses RLS for bulk writes
ANTHROPIC_API_KEY=
FIRECRAWL_API_KEY=
```

## Schedules (`src/index.ts`, cron in UTC)

| Cron | AEST | Retailers | Concurrency |
|---|---|---|---|
| `0 16 * * *` | 02:00 daily | Woolworths, Coles, Chemist Warehouse, Priceline, Kmart, Big W, Target, Bunnings, Officeworks, JB Hi-Fi, Harvey Norman, Petbarn | 3 |
| `0 18 * * 2,5` | 04:00 Tue/Fri | Aldi (Special Buys) | 1 |
| `0 20 * * 0` | 06:00 Sun | Costco, IKEA | 2 |

## Adding a new retailer

1. Create `src/scrapers/<slug>.ts`:
   ```ts
   import { createRetailerScraper } from "./retailer-factory.js";
   export const MyStoreScraper = createRetailerScraper(
     "my-store",
     "https://www.mystore.com.au/specials",
   );
   ```
2. Seed the retailer row in Supabase (`retailers` table) with the **same `slug`** —
   `upsertProductsFromScrape` looks the retailer up by slug and skips unknown ones.
   Add it to `supabase/migrations/005_seed_data.sql` or insert directly.
3. Import it in `src/index.ts` and add it to the appropriate schedule array
   (`dailyScrapers`, or a new `cron.schedule` block).
4. `npm run build`, then test with a temporary `--once` pointing at the new scraper.

## Testing locally

- `npm run scrape` runs the single-retailer path; watch the pino logs for
  `found / inserted / updated / errors` counts.
- Each run writes a `scrape_logs` row (`status`, counts, `error_message`) — check it in
  Supabase or the admin **System Health** page.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `Empty HTML from Firecrawl` | Firecrawl key invalid, or the retailer URL changed / is JS-gated. Verify the URL in a browser; adjust `waitFor` in `fetchWithFirecrawl`. |
| `Claude returned invalid JSON` | The HTML chunk had no clear promo data, or the model wrapped output in prose. The normaliser logs a 200-char preview and returns `[]`; check the preview in logs. |
| `Retailer not found: <slug>` | No `retailers` row with that slug — seed it (step 2 above). |
| 0 products but page has deals | Discount sanity filter (`validateProduct`) is dropping rows — confirm the page actually shows a struck-through regular price alongside the sale price. |
| Scrape log stuck on `running` | The process crashed mid-scrape; check Railway logs and Sentry. |
