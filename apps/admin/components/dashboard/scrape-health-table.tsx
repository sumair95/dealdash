import { Badge } from "@/components/ui/badge";
import { Card, CardHeader } from "@/components/ui/card";
import { Table, TBody, TD, THead, TH, TR } from "@/components/ui/table";
import { formatDate } from "@/lib/utils";

export type ScrapeHealthRow = {
  id: string;
  retailer_name: string;
  last_scraped_at: string | null;
  status: string;
  products_found: number;
  error_message: string | null;
};

function statusVariant(status: string) {
  switch (status) {
    case "success":
      return "success" as const;
    case "partial":
      return "warning" as const;
    case "failed":
      return "danger" as const;
    default:
      return "info" as const;
  }
}

export function ScrapeHealthTable({ rows }: { rows: ScrapeHealthRow[] }) {
  return (
    <Card>
      <CardHeader title="Scrape health" description="Latest scrape job per retailer" />
      <Table>
        <THead>
          <TR>
            <TH>Retailer</TH>
            <TH>Last scraped</TH>
            <TH>Status</TH>
            <TH>Products</TH>
            <TH>Errors</TH>
          </TR>
        </THead>
        <TBody>
          {rows.length === 0 ? (
            <TR>
              <TD className="py-8 text-center text-gray-400" >
                <span className="col-span-5">No scrape logs yet</span>
              </TD>
            </TR>
          ) : (
            rows.map((row) => (
              <TR key={row.id}>
                <TD>{row.retailer_name}</TD>
                <TD>{formatDate(row.last_scraped_at)}</TD>
                <TD>
                  <Badge variant={statusVariant(row.status)}>{row.status}</Badge>
                </TD>
                <TD>{row.products_found}</TD>
                <TD className="max-w-xs truncate text-red-600">
                  {row.error_message ?? "—"}
                </TD>
              </TR>
            ))
          )}
        </TBody>
      </Table>
    </Card>
  );
}
