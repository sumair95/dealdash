import {
  BaseScraper,
  type ScrapeResult,
  type ScrapedProduct,
} from "./base-scraper.js";
import { normaliseWithClaude } from "../ai/claude-normaliser.js";
import { logger } from "../utils/logger.js";

export function createRetailerScraper(
  retailerSlug: string,
  scrapeUrl: string,
): BaseScraper {
  return new (class extends BaseScraper {
    retailerSlug = retailerSlug;
    scrapeUrl = scrapeUrl;

    async scrape(): Promise<ScrapeResult> {
      const started = Date.now();
      try {
        const html = await this.fetchWithFirecrawl(this.scrapeUrl);
        if (!html) {
          return {
            retailer_slug: this.retailerSlug,
            products: [],
            error: "Empty HTML from Firecrawl",
            duration_ms: Date.now() - started,
          };
        }

        const rawProducts = await normaliseWithClaude(html, this.retailerSlug);
        const products = rawProducts.filter((p) => this.validateProduct(p));

        return {
          retailer_slug: this.retailerSlug,
          products,
          duration_ms: Date.now() - started,
        };
      } catch (error) {
        logger.error({ retailerSlug: this.retailerSlug, error }, "Scrape failed");
        return {
          retailer_slug: this.retailerSlug,
          products: [],
          error: error instanceof Error ? error.message : "Unknown error",
          duration_ms: Date.now() - started,
        };
      }
    }
  })();
}

export type { ScrapedProduct, ScrapeResult };
