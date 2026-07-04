import { AdminShell } from "@/components/layout/admin-shell";
import { Table, TBody, TD, THead, TH, TR } from "@/components/ui/table";
import { getProducts } from "@/lib/data";

export const dynamic = "force-dynamic";

export default async function ProductsPage({
  searchParams,
}: {
  searchParams: { q?: string };
}) {
  let products: Awaited<ReturnType<typeof getProducts>> = [];
  try {
    products = await getProducts(searchParams.q);
  } catch {
    // env not configured
  }

  return (
    <AdminShell title="Products">
      <form className="mb-6">
        <input
          name="q"
          defaultValue={searchParams.q ?? ""}
          placeholder="Search products…"
          className="h-10 w-full max-w-md rounded-lg border border-gray-300 px-3 text-sm"
        />
      </form>
      <Table>
        <THead>
          <TR>
            <TH>Name</TH>
            <TH>Brand</TH>
            <TH>Category</TH>
            <TH>Barcode</TH>
          </TR>
        </THead>
        <TBody>
          {products.map((p) => (
            <TR key={p.id}>
              <TD className="font-medium">{p.name}</TD>
              <TD>{p.brand ?? "—"}</TD>
              <TD>{(p.categories as { name?: string } | null)?.name ?? "—"}</TD>
              <TD>{p.barcode ?? "—"}</TD>
            </TR>
          ))}
        </TBody>
      </Table>
    </AdminShell>
  );
}
