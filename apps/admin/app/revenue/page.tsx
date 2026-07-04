import { AdminShell } from "@/components/layout/admin-shell";
import { RevenueChart } from "@/components/dashboard/revenue-chart";
import { StatsCard } from "@/components/dashboard/stats-card";
import { Card, CardHeader } from "@/components/ui/card";
import { getDashboardStats, getRevenueChartData } from "@/lib/data";

export const dynamic = "force-dynamic";

export default async function RevenuePage() {
  let premiumUsers = 0;
  let totalUsers = 0;

  try {
    const stats = await getDashboardStats();
    premiumUsers = stats.premiumUsers;
    totalUsers = stats.totalUsers;
  } catch {
    // env not configured
  }

  const mrr = premiumUsers * 5;
  const churnRate = totalUsers > 0 ? ((totalUsers - premiumUsers) / totalUsers) * 100 : 0;
  const revenueData = getRevenueChartData();

  return (
    <AdminShell title="Revenue">
      <div className="grid gap-6 md:grid-cols-3">
        <StatsCard label="MRR" value={`$${mrr.toFixed(2)}`} hint="AUD" />
        <StatsCard label="Premium subscribers" value={premiumUsers} />
        <StatsCard label="Free user ratio" value={`${churnRate.toFixed(1)}%`} />
      </div>
      <div className="mt-8">
        <RevenueChart data={revenueData} />
      </div>
      <Card className="mt-8">
        <CardHeader
          title="Stripe integration"
          description="Connect Stripe webhook for live revenue data. Currently showing estimates from Supabase subscription status."
        />
      </Card>
    </AdminShell>
  );
}
