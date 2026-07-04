import { createRetailerScraper } from "./retailer-factory.js";

export const PetbarnScraper = createRetailerScraper(
  "petbarn",
  "https://www.petbarn.com.au/sale",
);
