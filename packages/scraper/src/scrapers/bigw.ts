import { createRetailerScraper } from "./retailer-factory.js";

export const BigWScraper = createRetailerScraper(
  "bigw",
  "https://www.bigw.com.au/category/sale",
);
