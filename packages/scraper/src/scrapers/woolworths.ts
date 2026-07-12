import { createRetailerScraper } from "./retailer-factory.js";

export const WoolworthsScraper = createRetailerScraper(
  "woolworths",
  // /shop/catalogue is a location-gated catalogue browser that renders no
  // products to a static scrape. /shop/browse/specials is server-rendered and
  // exposes ~2000 on-special items directly.
  "https://www.woolworths.com.au/shop/browse/specials",
);
