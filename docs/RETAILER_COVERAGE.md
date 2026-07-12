# Retailer Coverage Status

Last updated: 2026-07-12

Which of the 15 retailers actually yield promotional data through the current
Firecrawl static-scrape + Claude pipeline, based on live testing.

## Summary: 9 of 15 working

| Retailer | Status | Static price signal | Notes |
|---|---|---|---|
| Coles | ✅ working | ~308 prices | Verified 23 products end-to-end |
| Woolworths | ✅ **fixed** | ~2000 prices | URL changed `/shop/catalogue` → `/shop/browse/specials`; 29 products |
| JB Hi-Fi | ✅ working | ~93 | |
| Officeworks | ✅ working | ~85 | |
| Bunnings | ✅ working | ~82 | |
| IKEA | ✅ working | ~77 | |
| Kmart | ✅ working | ~53 | |
| Target | ✅ working | ~50 | |
| Big W | ✅ working | ~13 | Lower yield; page may paginate |
| — | | | |
| Chemist Warehouse | ❌ needs work | 0 (client-side API) | Empty 3K shell; products load via XHR |
| Priceline | ❌ needs work | 0 (client-side API) | Empty ~4K shell |
| Costco | ❌ needs work | 0 | ~8K shell; likely membership-gated |
| Aldi | ❌ needs work | 0 | 67K of nav content; Special Buys grid loads via JS |
| Harvey Norman | ❌ needs work | 0 | 572K of nav content; product grid loads via JS |
| Petbarn | ❌ needs work | 0 | 61K nav content; verified 0 via Claude too |

## What was tried on the failing retailers

For the JS/location-gated retailers, the following were tested (on Woolworths and
Chemist Warehouse as representatives):

| Lever | Result |
|---|---|
| Longer `waitFor` (8–15s) | No change on gated shells |
| `location: { country: "AU" }` | No change |
| `proxy: "stealth"` | No change |
| `mobile: true` | No change |
| `actions` (scroll + wait to trigger lazy-load) | No change (still 0 prices) |
| **Alternate URL** | **Fixed Woolworths** (`/shop/browse/specials`); did not fix Chemist Warehouse |

**Conclusion:** the 6 remaining retailers render their product grids **client-side from
an internal JSON/XHR API**. A static HTML scrape — even a stealthed, scrolled, JS-rendered
one — never receives the product data, so there is nothing for Claude to extract. This is
not fixable with Firecrawl scrape options.

## Recommended approach for the remaining 6

Per retailer, in rough priority order (Chemist Warehouse and Aldi are the highest-value):

1. **Find the underlying product API.** Open the specials page in a browser with
   DevTools → Network → XHR/Fetch, and locate the JSON endpoint the page calls to load
   products (e.g. a `/api/.../specials` request). Call that endpoint directly in a custom
   scraper — no Firecrawl or Claude needed, and far more reliable than HTML parsing.
2. **Or use a server-rendered deep URL.** Some sites render a specific category's product
   grid server-side even when the top-level specials page doesn't (this is exactly what
   fixed Woolworths). Probe category-level specials URLs.
3. **Or an official data feed / affiliate catalogue** where available (e.g. some retailers
   publish price feeds to affiliate networks).

These are per-retailer custom scrapers, distinct from the generic
`createRetailerScraper()` factory. The factory + Firecrawl + Claude path remains the right
tool for the 9 server-rendered retailers.

## How this was tested

`packages/scraper` — probes hit Firecrawl `/v1/scrape` and counted `$`-price signals per
page; working retailers were confirmed by running the real pipeline (`npm run scrape`
pointed at the retailer) and checking `found`/`inserted` plus `get_today_deals`.
