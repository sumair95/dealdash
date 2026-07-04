import { createRetailerScraper } from "./retailer-factory.js";

export const AldiScraper = createRetailerScraper(
  "aldi",
  "https://www.aldi.com.au/en/special-buys/",
);
