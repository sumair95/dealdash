import type { ScrapedProduct } from "../scrapers/base-scraper.js";

export function isValidPrice(product: ScrapedProduct): boolean {
  if (!product.product_name?.trim()) return false;
  if (product.regular_price <= 0 || product.sale_price <= 0) return false;
  if (product.sale_price >= product.regular_price) return false;
  if (product.discount_pct < 1 || product.discount_pct > 99) return false;
  return true;
}
