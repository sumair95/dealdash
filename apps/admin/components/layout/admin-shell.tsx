import { Sidebar } from "@/components/layout/sidebar";

export function AdminShell({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <div className="flex flex-1 flex-col">
        <header className="flex h-16 items-center border-b border-gray-200 bg-white px-8">
          <h1 className="text-xl font-semibold text-gray-900">{title}</h1>
        </header>
        <main className="flex-1 p-8">{children}</main>
      </div>
    </div>
  );
}
