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

    const now = new Date().toISOString();
    const { data, error } = await supabase
      .from("price_history")
      .update({ is_active: false })
      .eq("is_active", true)
      .lt("promotion_ends_at", now)
      .select("id");
    if (error) return json({ error: "Failed to expire promotions" }, 500);

    return json({ ok: true, expired_count: (data ?? []).length }, 200);
  } catch (error) {
    console.error("cleanup-expired failed", error);
    return json({ error: "Internal server error" }, 500);
  }
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
