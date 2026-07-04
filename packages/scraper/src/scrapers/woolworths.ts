import { createRetailerScraper } from "./retailer-factory.js";

export const WoolworthsScraper = createRetailerScraper(
  "woolworths",
  "https://www.woolworths.com.au/shop/catalogue",
);
