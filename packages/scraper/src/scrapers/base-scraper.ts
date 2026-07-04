export interface ScrapedProduct {
  product_name: string;
  brand: string | null;
  category: string;
  regular_price: number;
  sale_price: number;
  discount_pct: number;
  promotion_type:
    | "weekly_special"
    | "clearance"
    | "bogo"
    | "multi_buy"
    | "catalogue"
    | "limited_time";
  promotion_notes: string | null;
  promotion_ends_at: string | null;
  product_url: string;
  image_url: string | null;
  barcode: string | null;
}

export interface ScrapeResult {
  retailer_slug: string;
  products: ScrapedProduct[];
  error?: string;
  duration_ms: number;
}

export abstract class BaseScraper {
  abstract retailerSlug: string;
  abstract scrapeUrl: string;

  abstract scrape(): Promise<ScrapeResult>;

  protected async fetchWithFirecrawl(url: string): Promise<string> {
    const response = await fetch("https://api.firecrawl.dev/v1/scrape", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.FIRECRAWL_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        url,
        formats: ["html"],
        onlyMainContent: true,
        waitFor: 2000,
      }),
    });

    const data = (await response.json()) as { data?: { html?: string } };
    return data.data?.html ?? "";
  }

  protected validateProduct(product: ScrapedProduct): boolean {
    if (!product.product_name || product.product_name.trim() === "") return false;
    if (product.regular_price <= 0 || product.sale_price <= 0) return false;
    if (product.sale_price >= product.regular_price) return false;
    if (product.discount_pct < 1 || product.discount_pct > 99) return false;
    return true;
  }
}
