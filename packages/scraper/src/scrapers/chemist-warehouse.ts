import { createRetailerScraper } from "./retailer-factory.js";

export const ChemistWarehouseScraper = createRetailerScraper(
  "chemist-warehouse",
  "https://www.chemistwarehouse.com.au/specials",
);
