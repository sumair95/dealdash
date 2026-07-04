import { AdminShell } from "@/components/layout/admin-shell";
import { Badge } from "@/components/ui/badge";
import { Card, CardHeader } from "@/components/ui/card";
import { Table, TBody, TD, THead, TH, TR } from "@/components/ui/table";
import { getSystemStats } from "@/lib/data";
import { formatDate } from "@/lib/utils";

export const dynamic = "force-dynamic";

export default async function SystemPage() {
  let counts: Record<string, number> = {};
  let recentLogs: Awaited<ReturnType<typeof getSystemStats>>["recentLogs"] = [];

  try {
    const stats = await getSystemStats();
    counts = stats.counts;
    recentLogs = stats.recentLogs;
  } catch {
    // env not configured
  }

  return (
    <AdminShell title="System Health">
      <div className="grid gap-4 md:grid-cols-3 lg:grid-cols-5">
        {Object.entries(counts).map(([table, count]) => (
          <Card key={table}>
            <p className="text-sm capitalize text-gray-500">{table.replace("_", " ")}</p>
            <p className="mt-1 text-2xl font-bold">{count.toLocaleString()}</p>
          </Card>
        ))}
      </div>

      <Card className="mt-8">
        <CardHeader title="Recent scrape logs" />
        <Table>
          <THead>
            <TR>
              <TH>Retailer</TH>
              <TH>Started</TH>
              <TH>Status</TH>
              <TH>Found</TH>
              <TH>Inserted</TH>
            </TR>
          </THead>
          <TBody>
            {recentLogs.map((log) => (
              <TR key={log.id}>
                <TD>{(log.retailers as { name?: string } | null)?.name ?? "—"}</TD>
                <TD>{formatDate(log.started_at)}</TD>
                <TD>
                  <Badge
                    variant={
                      log.status === "success"
                        ? "success"
                        : log.status === "failed"
                          ? "danger"
                          : "warning"
                    }
                  >
                    {log.status}
                  </Badge>
                </TD>
                <TD>{log.products_found}</TD>
                <TD>{log.products_inserted}</TD>
              </TR>
            ))}
          </TBody>
        </Table>
      </Card>
    </AdminShell>
  );
}
