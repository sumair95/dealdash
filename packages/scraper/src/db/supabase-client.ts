import { createClient } from "@supabase/supabase-js";

import type { ScrapedProduct } from "../scrapers/base-scraper.js";
import { logger } from "../utils/logger.js";

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
);

export async function upsertProductsFromScrape(
  retailerSlug: string,
  products: ScrapedProduct[],
  scrapeLogId: string,
): Promise<{ inserted: number; updated: number; errors: number; priceHistoryIds: string[] }> {
  const { data: retailer } = await supabase
    .from("retailers")
    .select("id")
    .eq("slug", retailerSlug)
    .single();

  if (!retailer) throw new Error(`Retailer not found: ${retailerSlug}`);

  let inserted = 0;
  let updated = 0;
  let errors = 0;
  const priceHistoryIds: string[] = [];

  for (const product of products) {
    try {
      let productId: string;

      if (product.barcode) {
        const { data: existing } = await supabase
          .from("products")
          .select("id")
          .eq("barcode", product.barcode)
          .maybeSingle();

        if (existing) {
          productId = existing.id;
        } else {
          const { data: newProduct, error } = await supabase
            .from("products")
            .insert({
              name: product.product_name,
              brand: product.brand,
              barcode: product.barcode,
              image_url: product.image_url,
            })
            .select("id")
            .single();
          if (error || !newProduct) throw error;
          productId = newProduct.id;
          inserted++;
        }
      } else {
        const { data: existing } = await supabase
          .from("products")
          .select("id")
          .ilike("name", product.product_name)
          .limit(1)
          .maybeSingle();

        if (existing) {
          productId = existing.id;
          updated++;
        } else {
          const { data: newProduct, error } = await supabase
            .from("products")
            .insert({
              name: product.product_name,
              brand: product.brand,
              image_url: product.image_url,
            })
            .select("id")
            .single();
          if (error || !newProduct) throw error;
          productId = newProduct.id;
          inserted++;
        }
      }

      const { data: retailerProduct, error: rpError } = await supabase
        .from("retailer_products")
        .upsert(
          {
            product_id: productId,
            retailer_id: retailer.id,
            product_url: product.product_url,
            image_url: product.image_url,
          },
          { onConflict: "product_id,retailer_id" },
        )
        .select("id")
        .single();

      if (rpError || !retailerProduct) throw rpError;

      await supabase
        .from("price_history")
        .update({ is_active: false })
        .eq("retailer_product_id", retailerProduct.id)
        .eq("is_active", true);

      const { data: priceRow, error: phError } = await supabase
        .from("price_history")
        .insert({
          retailer_product_id: retailerProduct.id,
          regular_price: product.regular_price,
          sale_price: product.sale_price,
          promotion_type: product.promotion_type,
          promotion_notes: product.promotion_notes,
          promotion_ends_at: product.promotion_ends_at,
          is_active: true,
        })
        .select("id")
        .single();

      if (phError || !priceRow) throw phError;
      priceHistoryIds.push(priceRow.id);
    } catch (err) {
      logger.error({ product: product.product_name, err }, "Failed processing product");
      errors++;
    }
  }

  await supabase
    .from("scrape_logs")
    .update({
      completed_at: new Date().toISOString(),
      products_found: products.length,
      products_inserted: inserted,
      products_updated: updated,
      status: errors > 0 && inserted + updated === 0 ? "failed" : errors > 0 ? "partial" : "success",
    })
    .eq("id", scrapeLogId);

  await supabase
    .from("retailers")
    .update({
      last_scraped_at: new Date().toISOString(),
      scrape_success_count: inserted + updated,
    })
    .eq("id", retailer.id);

  return { inserted, updated, errors, priceHistoryIds };
}

export { supabase };
