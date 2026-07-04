import { createAdminClient } from "./supabase";

export async function getDashboardStats() {
  const supabase = createAdminClient();

  const [users, premium, products, scrapeLogs] = await Promise.all([
    supabase.from("users").select("id", { count: "exact", head: true }),
    supabase
      .from("users")
      .select("id", { count: "exact", head: true })
      .eq("subscription_status", "premium"),
    supabase.from("products").select("id", { count: "exact", head: true }),
    supabase
      .from("scrape_logs")
      .select("products_found")
      .gte("started_at", new Date(Date.now() - 86400000).toISOString()),
  ]);

  const todayScraped =
    scrapeLogs.data?.reduce((sum, row) => sum + (row.products_found ?? 0), 0) ?? 0;

  return {
    totalUsers: users.count ?? 0,
    premiumUsers: premium.count ?? 0,
    totalProducts: products.count ?? 0,
    todayScraped,
    revenueMtd: (premium.count ?? 0) * 5,
  };
}

export async function getScrapeHealth() {
  const supabase = createAdminClient();

  const { data: retailers } = await supabase
    .from("retailers")
    .select("id, name, last_scraped_at")
    .order("name");

  const { data: logs } = await supabase
    .from("scrape_logs")
    .select("id, retailer_id, started_at, status, products_found, error_message")
    .order("started_at", { ascending: false });

  return (retailers ?? []).map((retailer) => {
    const latest = logs?.find((l) => l.retailer_id === retailer.id);
    return {
      id: latest?.id ?? retailer.id,
      retailer_name: retailer.name,
      last_scraped_at: latest?.started_at ?? retailer.last_scraped_at,
      status: latest?.status ?? "unknown",
      products_found: latest?.products_found ?? 0,
      error_message: latest?.error_message ?? null,
    };
  });
}

export async function getRetailers() {
  const supabase = createAdminClient();
  const { data } = await supabase
    .from("retailers")
    .select("*")
    .order("name");
  return data ?? [];
}

export async function getProducts(search?: string) {
  const supabase = createAdminClient();
  let query = supabase.from("products").select("*, categories(name)").order("name");
  if (search) query = query.ilike("name", `%${search}%`);
  const { data } = await query.limit(100);
  return data ?? [];
}

export async function getPromotions() {
  const supabase = createAdminClient();
  const { data } = await supabase
    .from("price_history")
    .select(
      "id, regular_price, sale_price, discount_pct, promotion_type, promotion_ends_at, is_active, retailer_products(product_url, products(name, brand), retailers(name))",
    )
    .eq("is_active", true)
    .order("discount_pct", { ascending: false })
    .limit(100);
  return data ?? [];
}

export async function getUsers(search?: string) {
  const supabase = createAdminClient();
  let query = supabase.from("users").select("*").order("created_at", { ascending: false });
  if (search) query = query.ilike("email", `%${search}%`);
  const { data } = await query.limit(100);
  return data ?? [];
}

export async function getNotifications() {
  const supabase = createAdminClient();
  const { data } = await supabase
    .from("notifications")
    .select("*")
    .order("sent_at", { ascending: false })
    .limit(50);
  return data ?? [];
}

export async function getSystemStats() {
  const supabase = createAdminClient();
  const tables = ["users", "products", "retailers", "price_history", "scrape_logs"];
  const counts: Record<string, number> = {};

  for (const table of tables) {
    const { count } = await supabase.from(table).select("id", { count: "exact", head: true });
    counts[table] = count ?? 0;
  }

  const { data: recentLogs } = await supabase
    .from("scrape_logs")
    .select("*, retailers(name)")
    .order("started_at", { ascending: false })
    .limit(20);

  return { counts, recentLogs: recentLogs ?? [] };
}

export function getRevenueChartData() {
  const months = [
    "Aug", "Sep", "Oct", "Nov", "Dec", "Jan",
    "Feb", "Mar", "Apr", "May", "Jun", "Jul",
  ];
  return months.map((month, i) => ({
    month,
    revenue: Math.round(120 + i * 35 + Math.random() * 50),
  }));
}
