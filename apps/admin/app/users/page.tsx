import { AdminShell } from "@/components/layout/admin-shell";
import { Badge } from "@/components/ui/badge";
import { Table, TBody, TD, THead, TH, TR } from "@/components/ui/table";
import { getUsers } from "@/lib/data";
import { formatDate } from "@/lib/utils";

export const dynamic = "force-dynamic";

export default async function UsersPage({
  searchParams,
}: {
  searchParams: { q?: string };
}) {
  let users: Awaited<ReturnType<typeof getUsers>> = [];
  try {
    users = await getUsers(searchParams.q);
  } catch {
    // env not configured
  }

  return (
    <AdminShell title="Users">
      <form className="mb-6">
        <input
          name="q"
          defaultValue={searchParams.q ?? ""}
          placeholder="Search by email…"
          className="h-10 w-full max-w-md rounded-lg border border-gray-300 px-3 text-sm"
        />
      </form>
      <Table>
        <THead>
          <TR>
            <TH>Email</TH>
            <TH>Name</TH>
            <TH>Status</TH>
            <TH>Searches</TH>
            <TH>Joined</TH>
          </TR>
        </THead>
        <TBody>
          {users.map((u) => (
            <TR key={u.id}>
              <TD>{u.email}</TD>
              <TD>{u.full_name ?? "—"}</TD>
              <TD>
                <Badge
                  variant={
                    u.subscription_status === "premium" ? "success" : "default"
                  }
                >
                  {u.subscription_status}
                </Badge>
              </TD>
              <TD>{u.search_count}</TD>
              <TD>{formatDate(u.created_at)}</TD>
            </TR>
          ))}
        </TBody>
      </Table>
    </AdminShell>
  );
}
