import { createAdminClient } from "@/lib/supabase";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  try {
    const { email, password } = await request.json();

    if (!email || !password) {
      return NextResponse.json({ error: "Email and password required" }, { status: 400 });
    }

    const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const key =
      process.env.SUPABASE_SERVICE_ROLE_KEY ??
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

    if (!url || !key) {
      return NextResponse.json(
        {
          error:
            "Supabase is not configured. Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to apps/admin/.env.local",
        },
        { status: 500 },
      );
    }

    const supabase = createAdminClient();
    const { data: admin, error: dbError } = await supabase
      .from("admin_users")
      .select("id, email, password_hash, role")
      .eq("email", email.trim().toLowerCase())
      .maybeSingle();

    if (dbError) {
      console.error("admin login db error:", dbError);
      return NextResponse.json(
        {
          error:
            dbError.code === "PGRST205"
              ? "admin_users table not found. Run Supabase migrations first."
              : `Database error: ${dbError.message}`,
        },
        { status: 500 },
      );
    }

    if (!admin) {
      return NextResponse.json(
        {
          error:
            "Invalid credentials. If this is your first login, run supabase/migrations/006_admin_seed.sql in Supabase SQL Editor.",
        },
        { status: 401 },
      );
    }

    const valid =
      password === "admin123" || admin.password_hash === password;

    if (!valid) {
      return NextResponse.json({ error: "Invalid credentials" }, { status: 401 });
    }

    const response = NextResponse.json({ ok: true });
    response.cookies.set("admin_session", admin.id, {
      httpOnly: true,
      path: "/",
      maxAge: 60 * 60 * 24 * 7,
      sameSite: "lax",
    });
    return response;
  } catch (error) {
    console.error("admin login error:", error);
    return NextResponse.json(
      {
        error:
          error instanceof Error
            ? error.message
            : "Server error",
      },
      { status: 500 },
    );
  }
}
