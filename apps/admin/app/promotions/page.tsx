import { AdminShell } from "@/components/layout/admin-shell";
import { Badge } from "@/components/ui/badge";
import { Table, TBody, TD, THead, TH, TR } from "@/components/ui/table";
import { getPromotions } from "@/lib/data";
import { formatCurrency, formatDate } from "@/lib/utils";

export const dynamic = "force-dynamic";

export default async function PromotionsPage() {
  let promotions: Awaited<ReturnType<typeof getPromotions>> = [];
  try {
    promotions = await getPromotions();
  } catch {
    // env not configured
  }

  return (
    <AdminShell title="Promotions">
      <Table>
        <THead>
          <TR>
            <TH>Product</TH>
            <TH>Retailer</TH>
            <TH>Regular</TH>
            <TH>Sale</TH>
            <TH>Discount</TH>
            <TH>Type</TH>
            <TH>Ends</TH>
          </TR>
        </THead>
        <TBody>
          {promotions.map((p) => {
            const rp = p.retailer_products as {
              products?: { name?: string } | { name?: string }[] | null;
              retailers?: { name?: string } | { name?: string }[] | null;
            } | null;
            const product = Array.isArray(rp?.products) ? rp?.products[0] : rp?.products;
            const retailer = Array.isArray(rp?.retailers) ? rp?.retailers[0] : rp?.retailers;
            return (
            <TR key={p.id}>
              <TD className="font-medium">
                {product?.name ?? "—"}
              </TD>
              <TD>{retailer?.name ?? "—"}</TD>
              <TD>{formatCurrency(Number(p.regular_price))}</TD>
              <TD className="font-semibold text-green-700">
                {formatCurrency(Number(p.sale_price))}
              </TD>
              <TD>
                <Badge variant="success">{Number(p.discount_pct).toFixed(0)}%</Badge>
              </TD>
              <TD>{p.promotion_type ?? "—"}</TD>
              <TD>{formatDate(p.promotion_ends_at)}</TD>
            </TR>
            );
          })}
        </TBody>
      </Table>
    </AdminShell>
  );
}
