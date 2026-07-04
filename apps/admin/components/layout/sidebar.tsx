"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Activity,
  Bell,
  DollarSign,
  LayoutDashboard,
  Package,
  ShoppingBag,
  Store,
  Tag,
  Users,
} from "lucide-react";

import { cn } from "@/lib/utils";

const navItems = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/retailers", label: "Retailers", icon: Store },
  { href: "/products", label: "Products", icon: Package },
  { href: "/promotions", label: "Promotions", icon: Tag },
  { href: "/users", label: "Users", icon: Users },
  { href: "/revenue", label: "Revenue", icon: DollarSign },
  { href: "/notifications", label: "Notifications", icon: Bell },
  { href: "/system", label: "System", icon: Activity },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="flex w-64 flex-col border-r border-gray-200 bg-white">
      <div className="flex h-16 items-center gap-2 border-b border-gray-200 px-6">
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-brand text-white">
          <ShoppingBag className="h-5 w-5" />
        </div>
        <div>
          <p className="font-semibold text-gray-900">DealDash</p>
          <p className="text-xs text-gray-500">Admin Portal</p>
        </div>
      </div>
      <nav className="flex-1 space-y-1 p-4">
        {navItems.map(({ href, label, icon: Icon }) => {
          const active =
            href === "/" ? pathname === "/" : pathname.startsWith(href);
          return (
            <Link
              key={href}
              href={href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                active
                  ? "bg-brand/10 text-brand"
                  : "text-gray-600 hover:bg-gray-100 hover:text-gray-900",
              )}
            >
              <Icon className="h-4 w-4" />
              {label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
