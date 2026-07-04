import { createRetailerScraper } from "./retailer-factory.js";

export const PricelineScraper = createRetailerScraper(
  "priceline",
  "https://www.priceline.com.au/offers",
);
