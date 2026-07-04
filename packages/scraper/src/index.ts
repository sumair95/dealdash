import cron from "node-cron";

import { supabase, upsertProductsFromScrape } from "./db/supabase-client.js";
import { AldiScraper } from "./scrapers/aldi.js";
import { BigWScraper } from "./scrapers/bigw.js";
import { BunningsScraper } from "./scrapers/bunnings.js";
import type { BaseScraper } from "./scrapers/base-scraper.js";
import { ChemistWarehouseScraper } from "./scrapers/chemist-warehouse.js";
import { ColesScraper } from "./scrapers/coles.js";
import { CostcoAUScraper } from "./scrapers/costco-au.js";
import { HarveyNormanScraper } from "./scrapers/harvey-norman.js";
import { IKEAAUScraper } from "./scrapers/ikea-au.js";
import { JBHifiScraper } from "./scrapers/jbhifi.js";
import { KmartScraper } from "./scrapers/kmart.js";
import { OfficeworksScraper } from "./scrapers/officeworks.js";
import { PetbarnScraper } from "./scrapers/petbarn.js";
import { PricelineScraper } from "./scrapers/priceline.js";
import { TargetAUScraper } from "./scrapers/target-au.js";
import { WoolworthsScraper } from "./scrapers/woolworths.js";
import { logger } from "./utils/logger.js";

const dailyScrapers: BaseScraper[] = [
  WoolworthsScraper,
  ColesScraper,
  ChemistWarehouseScraper,
  PricelineScraper,
  KmartScraper,
  BigWScraper,
  TargetAUScraper,
  BunningsScraper,
  OfficeworksScraper,
  JBHifiScraper,
  HarveyNormanScraper,
  PetbarnScraper,
];

async function notifyPriceInsert(priceHistoryIds: string[]): Promise<void> {
  if (!priceHistoryIds.length) return;
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceKey) return;

  try {
    await fetch(`${supabaseUrl}/functions/v1/on-price-insert`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${serviceKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ price_history_ids: priceHistoryIds }),
    });
  } catch (error) {
    logger.error({ error }, "Failed to call on-price-insert edge function");
  }
}

export async function runScraper(scraper: BaseScraper): Promise<void> {
  const { data: retailer } = await supabase
    .from("retailers")
    .select("id")
    .eq("slug", scraper.retailerSlug)
    .single();

  const { data: scrapeLog, error: logError } = await supabase
    .from("scrape_logs")
    .insert({
      retailer_id: retailer?.id ?? null,
      status: "running",
    })
    .select("id")
    .single();

  if (logError || !scrapeLog) {
    logger.error({ slug: scraper.retailerSlug, logError }, "Failed to create scrape log");
    return;
  }

  logger.info({ slug: scraper.retailerSlug }, "Starting scrape");

  const result = await scraper.scrape();

  if (result.error) {
    await supabase
      .from("scrape_logs")
      .update({
        completed_at: new Date().toISOString(),
        error_message: result.error,
        status: "failed",
      })
      .eq("id", scrapeLog.id);
    logger.error({ slug: scraper.retailerSlug, error: result.error }, "Scrape failed");
    return;
  }

  const writeResult = await upsertProductsFromScrape(
    scraper.retailerSlug,
    result.products,
    scrapeLog.id,
  );

  await notifyPriceInsert(writeResult.priceHistoryIds);

  logger.info(
    {
      slug: scraper.retailerSlug,
      found: result.products.length,
      inserted: writeResult.inserted,
      updated: writeResult.updated,
      errors: writeResult.errors,
      duration_ms: result.duration_ms,
    },
    "Scrape completed",
  );
}

export async function runWithConcurrency(
  scrapers: BaseScraper[],
  limit: number,
): Promise<void> {
  const queue = [...scrapers];
  const workers = Array.from({ length: Math.min(limit, queue.length) }, async () => {
    while (queue.length > 0) {
      const scraper = queue.shift();
      if (scraper) await runScraper(scraper);
    }
  });
  await Promise.all(workers);
}

async function runDailyBatch(): Promise<void> {
  logger.info("Starting daily scrape batch");
  await runWithConcurrency(dailyScrapers, 3);
}

async function runOnce(): Promise<void> {
  logger.info("Running single scraper (Woolworths) for test");
  await runScraper(WoolworthsScraper);
}

function startScheduler(): void {
  cron.schedule("0 16 * * *", runDailyBatch);
  cron.schedule("0 18 * * 2,5", () => runScraper(AldiScraper));
  cron.schedule("0 20 * * 0", () =>
    runWithConcurrency([CostcoAUScraper, IKEAAUScraper], 2),
  );
  logger.info("Scraper cron scheduler started");
}

const isOnce = process.argv.includes("--once");

if (isOnce) {
  runOnce().catch((err) => {
    logger.error({ err }, "One-off scrape failed");
    process.exit(1);
  });
} else {
  startScheduler();
  logger.info("DealDash scraper service running");
}
