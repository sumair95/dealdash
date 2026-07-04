import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type GateResponse =
  | { allowed: true; remaining: number | null }
  | { allowed: false; remaining: 0; show_paywall: true };

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
    if (!authHeader) {
      return json({ error: "Missing Authorization header" }, 401);
    }

    const body = await req.json();
    const userId = body?.user_id as string | undefined;
    if (!userId) {
      return json({ error: "user_id is required" }, 400);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: authUser, error: authErr } = await supabase.auth.getUser();
    if (authErr || !authUser.user || authUser.user.id !== userId) {
      return json({ error: "Unauthorized" }, 401);
    }

    const { data: user, error: userErr } = await supabase
      .from("users")
      .select("subscription_status,search_count")
      .eq("id", userId)
      .single();
    if (userErr || !user) {
      return json({ error: "User not found" }, 404);
    }

    if (user.subscription_status === "premium") {
      const payload: GateResponse = { allowed: true, remaining: null };
      return json(payload, 200);
    }

    if (user.search_count < 10) {
      const nextCount = user.search_count + 1;
      const remaining = 10 - nextCount;

      const { error: incErr } = await supabase.rpc("increment_search_count", { p_user_id: userId });
      if (incErr) return json({ error: "Failed to increment search count" }, 500);

      const { error: logErr } = await supabase.from("search_logs").insert({
        user_id: userId,
        query: body?.query ?? null,
        result_count: body?.result_count ?? null,
      });
      if (logErr) return json({ error: "Failed to log search usage" }, 500);

      const payload: GateResponse = { allowed: true, remaining };
      return json(payload, 200);
    }

    const payload: GateResponse = { allowed: false, remaining: 0, show_paywall: true };
    return json(payload, 200);
  } catch (error) {
    console.error("check-freemium-gate failed", error);
    return json({ error: "Internal server error" }, 500);
  }
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
