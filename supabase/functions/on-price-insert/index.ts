import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "Missing Authorization header" }, 401);

    const { price_history_ids: priceHistoryIds } = await req.json();
    if (!Array.isArray(priceHistoryIds) || priceHistoryIds.length === 0) {
      return json({ error: "price_history_ids must be a non-empty array" }, 400);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: authUser, error: authErr } = await supabase.auth.getUser();
    if (authErr || !authUser.user) return json({ error: "Unauthorized" }, 401);

    const { data: prices, error: priceErr } = await supabase
      .from("price_history")
      .select("id, sale_price, discount_pct, retailer_products!inner(product_id, retailer_id, products(name), retailers(name))")
      .in("id", priceHistoryIds);
    if (priceErr) return json({ error: "Failed loading price history records" }, 500);

    let sentCount = 0;
    for (const price of prices ?? []) {
      const retailerProduct = price.retailer_products as { product_id: string; retailer_id: string; products: { name: string }; retailers: { name: string } };
      const { data: watchers } = await supabase
        .from("watchlist")
        .select("user_id")
        .eq("product_id", retailerProduct.product_id);
      if (!watchers?.length) continue;

      for (const watcher of watchers) {
        const title = `${Math.round(Number(price.discount_pct))}% off at ${retailerProduct.retailers.name}`;
        const body = `${retailerProduct.products.name} now on sale for AUD ${Number(price.sale_price).toFixed(2)}`;

        await supabase.from("notifications").insert({
          user_id: watcher.user_id,
          title,
          body,
          notification_type: "price_drop",
          product_id: retailerProduct.product_id,
          retailer_id: retailerProduct.retailer_id,
          sent_at: new Date().toISOString(),
        });
        sentCount += 1;
      }
    }

    return json({ ok: true, notifications_logged: sentCount }, 200);
  } catch (error) {
    console.error("on-price-insert failed", error);
    return json({ error: "Internal server error" }, 500);
  }
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
