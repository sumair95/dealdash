import { createRetailerScraper } from "./retailer-factory.js";

export const HarveyNormanScraper = createRetailerScraper(
  "harvey-norman",
  "https://www.harveynorman.com.au/catalogues-specials",
);
