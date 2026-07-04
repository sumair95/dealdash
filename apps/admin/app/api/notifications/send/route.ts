import { NextResponse } from "next/server";

import { createAdminClient } from "@/lib/supabase";

export async function POST(request: Request) {
  try {
    const { title, body } = await request.json();
    if (!title || !body) {
      return NextResponse.json({ error: "Title and body required" }, { status: 400 });
    }

    const supabase = createAdminClient();
    const { data: users } = await supabase.from("users").select("id");

    if (!users?.length) {
      return NextResponse.json({ error: "No users found" }, { status: 404 });
    }

    const rows = users.map((u) => ({
      user_id: u.id,
      title,
      body,
      notification_type: "manual_admin",
    }));

    const { error } = await supabase.from("notifications").insert(rows);
    if (error) throw error;

    return NextResponse.json({ ok: true, recipients: users.length });
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Send failed" },
      { status: 500 },
    );
  }
}
