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

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: authUser, error: authErr } = await supabase.auth.getUser();
    if (authErr || !authUser.user) return json({ error: "Unauthorized" }, 401);

    const { data: deals, error: dealsErr } = await supabase.rpc("get_today_deals", { p_limit: 50 });
    if (dealsErr) return json({ error: "Failed calling get_today_deals" }, 500);

    const { error: cacheErr } = await supabase.from("deal_cache").insert({
      ranked_at: new Date().toISOString(),
      deals: deals ?? [],
    });
    if (cacheErr) return json({ error: "Failed writing deal cache" }, 500);

    return json({ ok: true, deal_count: (deals ?? []).length }, 200);
  } catch (error) {
    console.error("daily-deal-rank failed", error);
    return json({ error: "Internal server error" }, 500);
  }
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
