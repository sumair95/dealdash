import { createRetailerScraper } from "./retailer-factory.js";

export const ColesScraper = createRetailerScraper(
  "coles",
  "https://www.coles.com.au/on-special",
);
