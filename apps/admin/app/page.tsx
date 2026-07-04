import { AdminShell } from "@/components/layout/admin-shell";
import { RevenueChart } from "@/components/dashboard/revenue-chart";
import { ScrapeHealthTable } from "@/components/dashboard/scrape-health-table";
import { StatsCard } from "@/components/dashboard/stats-card";
import {
  getDashboardStats,
  getRevenueChartData,
  getScrapeHealth,
} from "@/lib/data";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  let stats = {
    totalUsers: 0,
    premiumUsers: 0,
    totalProducts: 0,
    todayScraped: 0,
    revenueMtd: 0,
  };
  let scrapeHealth: Awaited<ReturnType<typeof getScrapeHealth>> = [];

  try {
    [stats, scrapeHealth] = await Promise.all([
      getDashboardStats(),
      getScrapeHealth(),
    ]);
  } catch {
    // Supabase env may not be configured yet
  }

  const revenueData = getRevenueChartData();

  return (
    <AdminShell title="Dashboard">
      <div className="grid gap-6 md:grid-cols-2 xl:grid-cols-4">
        <StatsCard label="Total Users" value={stats.totalUsers} />
        <StatsCard label="Premium Users" value={stats.premiumUsers} />
        <StatsCard label="Products Scraped Today" value={stats.todayScraped} />
        <StatsCard
          label="Revenue MTD"
          value={`$${stats.revenueMtd.toFixed(2)}`}
          hint="AUD estimated from premium subs"
        />
      </div>
      <div className="mt-8 grid gap-6 xl:grid-cols-2">
        <RevenueChart data={revenueData} />
        <ScrapeHealthTable rows={scrapeHealth} />
      </div>
    </AdminShell>
  );
}
