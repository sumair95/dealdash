import { createRetailerScraper } from "./retailer-factory.js";

export const BunningsScraper = createRetailerScraper(
  "bunnings",
  "https://www.bunnings.com.au/specials",
);
