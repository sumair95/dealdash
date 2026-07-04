import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@16.9.0";

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

    const { user_id: userId, success_url: successUrl, cancel_url: cancelUrl } = await req.json();
    if (!userId || !successUrl || !cancelUrl) {
      return json({ error: "user_id, success_url and cancel_url are required" }, 400);
    }

    const stripeSecret = Deno.env.get("STRIPE_SECRET_KEY");
    const stripePriceId = Deno.env.get("STRIPE_PRICE_ID_MONTHLY");
    if (!stripeSecret || !stripePriceId) {
      return json({ error: "Stripe environment variables are missing" }, 500);
    }
    const stripe = new Stripe(stripeSecret);

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
      .select("id,email,full_name,stripe_customer_id")
      .eq("id", userId)
      .single();
    if (userErr || !user) return json({ error: "User not found" }, 404);

    let customerId = user.stripe_customer_id as string | null;
    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email,
        name: user.full_name ?? undefined,
        metadata: { user_id: user.id },
      });
      customerId = customer.id;
      await supabase.from("users").update({ stripe_customer_id: customerId }).eq("id", userId);
    }

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      customer: customerId,
      line_items: [{ price: stripePriceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
      metadata: { user_id: userId },
      subscription_data: { metadata: { user_id: userId } },
    });

    return json({ checkout_url: session.url }, 200);
  } catch (error) {
    console.error("stripe-create-checkout failed", error);
    return json({ error: "Internal server error" }, 500);
  }
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
