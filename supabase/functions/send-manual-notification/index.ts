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

    const { title, body, user_ids: userIds } = await req.json();
    if (!title || !body) return json({ error: "title and body are required" }, 400);

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: authUser, error: authErr } = await supabase.auth.getUser();
    if (authErr || !authUser.user?.email) return json({ error: "Unauthorized" }, 401);

    const { data: admin } = await supabase
      .from("admin_users")
      .select("id")
      .eq("email", authUser.user.email)
      .maybeSingle();
    if (!admin) return json({ error: "Forbidden: admin access required" }, 403);

    let targetIds: string[] = [];
    if (Array.isArray(userIds) && userIds.length > 0) {
      targetIds = userIds;
    } else {
      const { data: users } = await supabase
        .from("users")
        .select("id")
        .in("subscription_status", ["free", "premium", "past_due", "cancelled"]);
      targetIds = (users ?? []).map((u) => u.id as string);
    }

    if (!targetIds.length) return json({ ok: true, recipients: 0 }, 200);

    const rows = targetIds.map((id) => ({
      user_id: id,
      title,
      body,
      notification_type: "manual_admin",
      sent_at: new Date().toISOString(),
    }));
    const { error: insertErr } = await supabase.from("notifications").insert(rows);
    if (insertErr) return json({ error: "Failed creating notification records" }, 500);

    return json({ ok: true, recipients: targetIds.length }, 200);
  } catch (error) {
    console.error("send-manual-notification failed", error);
    return json({ error: "Internal server error" }, 500);
  }
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
