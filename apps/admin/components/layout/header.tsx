"use client";

import { LogOut } from "lucide-react";
import { useRouter } from "next/navigation";

import { Button } from "@/components/ui/button";

export function Header({ title }: { title: string }) {
  const router = useRouter();

  return (
    <header className="flex h-16 items-center justify-between border-b border-gray-200 bg-white px-8">
      <h1 className="text-xl font-semibold text-gray-900">{title}</h1>
      <Button
        variant="outline"
        size="sm"
        onClick={() => {
          document.cookie = "admin_session=; path=/; max-age=0";
          router.push("/login");
        }}
      >
        <LogOut className="mr-2 h-4 w-4" />
        Logout
      </Button>
    </header>
  );
}
