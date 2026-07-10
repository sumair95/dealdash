import Anthropic from "@anthropic-ai/sdk";

import type { ScrapedProduct } from "../scrapers/base-scraper.js";
import { retry } from "../utils/retry.js";
import { logger } from "../utils/logger.js";

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

const SYSTEM_PROMPT = `You are a retail data extraction specialist for Australian shopping.
Extract ALL promotional/discounted products from the HTML provided.

CRITICAL RULES:
- Only include products where sale_price is LESS THAN regular_price
- If you cannot find a clear regular price and sale price pair, SKIP the product
- discount_pct = round((regular_price - sale_price) / regular_price * 100, 2)
- promotion_ends_at must be a valid ISO 8601 date string or null
- All prices must be in AUD as numbers (not strings)
- product_url must be absolute URL

Return ONLY a valid JSON array. No commentary. No markdown fences.
If no promotional products found, return empty array: []

JSON structure for each product:
{
  "product_name": "string",
  "brand": "string or null",
  "category": "Grocery|Household|Personal Care|Baby Products|Medicines|Electronics|Garden|Hardware|Other",
  "regular_price": number,
  "sale_price": number,
  "discount_pct": number,
  "promotion_type": "weekly_special|clearance|bogo|multi_buy|catalogue|limited_time",
  "promotion_notes": "string or null",
  "promotion_ends_at": "ISO string or null",
  "product_url": "string",
  "image_url": "string or null",
  "barcode": "string or null"
}`;

// Claude sometimes wraps the array in a prose preamble and/or a ```json fence
// despite the system prompt. Extract the JSON array robustly before parsing so a
// successful extraction isn't discarded over formatting.
function extractJsonArray(text: string): unknown {
  let t = text.trim();
  const fence = t.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fence) t = fence[1].trim();
  const start = t.indexOf("[");
  const end = t.lastIndexOf("]");
  if (start !== -1 && end !== -1 && end > start) t = t.slice(start, end + 1);
  return JSON.parse(t);
}

const MAX_CHUNK_SIZE = 50000;
const MAX_CHUNKS = 8; // safety cap so a huge page can't run up unbounded cost

async function extractChunk(
  chunk: string,
  retailerName: string,
): Promise<ScrapedProduct[]> {
  const message = await retry(() =>
    client.messages.create({
      model: "claude-sonnet-5",
      max_tokens: 8192, // room for a full product array per chunk (was 4096)
      // Structured extraction against a fixed schema — no reasoning needed.
      // Sonnet 5 runs adaptive thinking when `thinking` is omitted, so disable
      // it explicitly to keep this nightly, high-volume call fast and cheap.
      thinking: { type: "disabled" },
      system: SYSTEM_PROMPT,
      messages: [
        {
          role: "user",
          content: `Retailer: ${retailerName}\n\nHTML Content:\n${chunk}`,
        },
      ],
    }),
  );

  const block = message.content[0];
  const responseText = block.type === "text" ? block.text : "";

  try {
    const products = extractJsonArray(responseText) as ScrapedProduct[];
    return Array.isArray(products) ? products : [];
  } catch {
    logger.error(
      { retailerName, preview: responseText.slice(0, 200) },
      "Claude returned invalid JSON",
    );
    return [];
  }
}

// A retailer specials page usually exceeds one 50K-char chunk, so process the
// whole page chunk by chunk and accumulate — otherwise every product past the
// first chunk is silently lost.
export async function normaliseWithClaude(
  htmlContent: string,
  retailerName: string,
): Promise<ScrapedProduct[]> {
  if (!htmlContent) return [];
  const totalChunks = Math.min(
    MAX_CHUNKS,
    Math.max(1, Math.ceil(htmlContent.length / MAX_CHUNK_SIZE)),
  );
  const all: ScrapedProduct[] = [];
  for (let i = 0; i < totalChunks; i++) {
    const chunk = htmlContent.slice(
      i * MAX_CHUNK_SIZE,
      (i + 1) * MAX_CHUNK_SIZE,
    );
    if (!chunk) break;
    all.push(...(await extractChunk(chunk, retailerName)));
  }
  return all;
}

export async function generateNotificationCopy(
  productName: string,
  retailerName: string,
  salePrice: number,
  regularPrice: number,
  discountPct: number,
  promotionType: string,
): Promise<{ title: string; body: string }> {
  const message = await retry(() =>
    client.messages.create({
      model: "claude-sonnet-5",
      max_tokens: 200,
      thinking: { type: "disabled" },
      messages: [
        {
          role: "user",
          content: `Generate a concise, exciting push notification for an Australian shopping deals app.
Product: ${productName}
Retailer: ${retailerName}
Regular Price: $${regularPrice.toFixed(2)}
Sale Price: $${salePrice.toFixed(2)}
Discount: ${discountPct.toFixed(0)}% off
Promotion Type: ${promotionType}

Return ONLY valid JSON: {"title": "max 50 chars", "body": "max 100 chars"}
Make it feel urgent and exciting. Use $ for prices. Mention the retailer.`,
        },
      ],
    }),
  );

  const block = message.content[0];
  const text = block.type === "text" ? block.text : "";
  try {
    return JSON.parse(text) as { title: string; body: string };
  } catch {
    return {
      title: `${discountPct.toFixed(0)}% off at ${retailerName}!`,
      body: `${productName} now only $${salePrice.toFixed(2)}`,
    };
  }
}
