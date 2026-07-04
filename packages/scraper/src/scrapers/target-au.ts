import { createRetailerScraper } from "./retailer-factory.js";

export const TargetAUScraper = createRetailerScraper(
  "target-au",
  "https://www.target.com.au/sale",
);
