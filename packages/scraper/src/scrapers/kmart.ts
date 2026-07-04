import { createRetailerScraper } from "./retailer-factory.js";

export const KmartScraper = createRetailerScraper(
  "kmart",
  "https://www.kmart.com.au/sale",
);
