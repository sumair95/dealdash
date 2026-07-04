import { AdminShell } from "@/components/layout/admin-shell";
import { NotificationForm } from "@/components/notifications/notification-form";
import { Table, TBody, TD, THead, TH, TR } from "@/components/ui/table";
import { getNotifications } from "@/lib/data";
import { formatDate } from "@/lib/utils";

export const dynamic = "force-dynamic";

export default async function NotificationsPage() {
  let notifications: Awaited<ReturnType<typeof getNotifications>> = [];
  try {
    notifications = await getNotifications();
  } catch {
    // env not configured
  }

  return (
    <AdminShell title="Notifications">
      <NotificationForm />
      <div className="mt-8">
        <h2 className="mb-4 text-lg font-semibold">Notification history</h2>
        <Table>
          <THead>
            <TR>
              <TH>Sent at</TH>
              <TH>Title</TH>
              <TH>Body</TH>
              <TH>Type</TH>
            </TR>
          </THead>
          <TBody>
            {notifications.map((n) => (
              <TR key={n.id}>
                <TD>{formatDate(n.sent_at)}</TD>
                <TD className="font-medium">{n.title}</TD>
                <TD className="max-w-md truncate">{n.body}</TD>
                <TD>{n.notification_type ?? "—"}</TD>
              </TR>
            ))}
          </TBody>
        </Table>
      </div>
    </AdminShell>
  );
}
