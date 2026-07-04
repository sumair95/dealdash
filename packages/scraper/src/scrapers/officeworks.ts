import { createRetailerScraper } from "./retailer-factory.js";

export const OfficeworksScraper = createRetailerScraper(
  "officeworks",
  "https://www.officeworks.com.au/information/catalogues-offers",
);
