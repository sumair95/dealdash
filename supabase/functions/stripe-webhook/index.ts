import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@16.9.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, stripe-signature",
};

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const stripeSecret = Deno.env.get("STRIPE_SECRET_KEY");
    const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
    if (!stripeSecret || !webhookSecret) {
      return json({ error: "Stripe environment variables are missing" }, 500);
    }

    const stripe = new Stripe(stripeSecret);
    const signature = req.headers.get("stripe-signature");
    if (!signature) return json({ error: "Missing stripe-signature header" }, 400);

    const rawBody = await req.text();
    const event = await stripe.webhooks.constructEventAsync(rawBody, signature, webhookSecret);

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    if (
      event.type === "customer.subscription.created" ||
      event.type === "customer.subscription.updated" ||
      event.type === "customer.subscription.deleted"
    ) {
      const subscription = event.data.object as Stripe.Subscription;
      const userId = subscription.metadata?.user_id;
      if (userId) {
        const status = mapSubscriptionStatus(subscription.status);
        await supabase.from("users").update({
          subscription_status: status,
          stripe_subscription_id: subscription.id,
        }).eq("id", userId);

        await supabase.from("subscriptions").upsert({
          user_id: userId,
          stripe_subscription_id: subscription.id,
          stripe_price_id: subscription.items.data[0]?.price.id ?? null,
          status: subscription.status,
          current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
          current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
          cancel_at_period_end: subscription.cancel_at_period_end,
        }, { onConflict: "stripe_subscription_id" });
      }
    }

    if (event.type === "invoice.payment_failed" || event.type === "invoice.payment_succeeded") {
      const invoice = event.data.object as Stripe.Invoice;
      const customerId = typeof invoice.customer === "string" ? invoice.customer : null;
      if (customerId) {
        const newStatus = event.type === "invoice.payment_failed" ? "past_due" : "premium";
        await supabase.from("users").update({ subscription_status: newStatus }).eq("stripe_customer_id", customerId);
      }
    }

    return json({ ok: true }, 200);
  } catch (error) {
    console.error("stripe-webhook failed", error);
    return json({ error: "Webhook processing failed" }, 400);
  }
});

function mapSubscriptionStatus(status: string): "free" | "premium" | "cancelled" | "past_due" {
  if (status === "active" || status === "trialing") return "premium";
  if (status === "past_due" || status === "unpaid") return "past_due";
  if (status === "canceled" || status === "incomplete_expired") return "cancelled";
  return "free";
}

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
