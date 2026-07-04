import { AdminShell } from "@/components/layout/admin-shell";
import { Badge } from "@/components/ui/badge";
import { Table, TBody, TD, THead, TH, TR } from "@/components/ui/table";
import { getRetailers } from "@/lib/data";
import { formatDate } from "@/lib/utils";

export const dynamic = "force-dynamic";

export default async function RetailersPage() {
  let retailers: Awaited<ReturnType<typeof getRetailers>> = [];
  try {
    retailers = await getRetailers();
  } catch {
    // env not configured
  }

  return (
    <AdminShell title="Retailers">
      <Table>
        <THead>
          <TR>
            <TH>Name</TH>
            <TH>Slug</TH>
            <TH>Active</TH>
            <TH>Last Scraped</TH>
            <TH>Scrape URL</TH>
          </TR>
        </THead>
        <TBody>
          {retailers.map((r) => (
            <TR key={r.id}>
              <TD className="font-medium">{r.name}</TD>
              <TD>{r.slug}</TD>
              <TD>
                <Badge variant={r.is_active ? "success" : "default"}>
                  {r.is_active ? "Active" : "Inactive"}
                </Badge>
              </TD>
              <TD>{formatDate(r.last_scraped_at)}</TD>
              <TD className="max-w-xs truncate">{r.scrape_url}</TD>
            </TR>
          ))}
        </TBody>
      </Table>
    </AdminShell>
  );
}
