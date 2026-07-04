import { createRetailerScraper } from "./retailer-factory.js";

export const CostcoAUScraper = createRetailerScraper(
  "costco-au",
  "https://www.costco.com.au/Savings",
);
