import { createRetailerScraper } from "./retailer-factory.js";

export const IKEAAUScraper = createRetailerScraper(
  "ikea-au",
  "https://www.ikea.com/au/en/offers/",
);
