# Supabase setup for DealDash

You do **not** need to write table SQL yourself. All migrations already exist in:

`dealdash/supabase/migrations/`

Run them **once** on your cloud project: `yactklxxcianiaymvloa`

---

## Option A (recommended): Supabase CLI

From the `dealdash` folder:

```bash
# 1. Install CLI (if needed)
npm install -g supabase

# 2. Log in
supabase login

# 3. Link your project
supabase link --project-ref yactklxxcianiaymvloa

# 4. Push all migrations
supabase db push
```

When prompted, enter your **database password** from:
Supabase Dashboard → Project Settings → Database

---

## Option B: Supabase SQL Editor (no CLI)

1. Open [Supabase Dashboard](https://supabase.com/dashboard/project/yactklxxcianiaymvloa)
2. Go to **SQL Editor** → **New query**
3. Run each file **in this exact order** (copy/paste full file contents):

| Order | File |
|------|------|
| 1 | `supabase/migrations/001_initial_schema.sql` |
| 2 | `supabase/migrations/002_rls_policies.sql` |
| 3 | `supabase/migrations/003_functions.sql` |
| 4 | `supabase/migrations/004_triggers.sql` |
| 5 | `supabase/migrations/005_seed_data.sql` |

4. Click **Run** after each file.

---

## Verify tables were created

In SQL Editor, run:

```sql
select table_name
from information_schema.tables
where table_schema = 'public'
order by table_name;
```

You should see tables including: `retailers`, `categories`, `products`, `users`, `watchlist`, `price_history`.

Check seed data:

```sql
select count(*) as retailer_count from public.retailers;
select count(*) as product_count from public.products;
```

Expected: **15 retailers**, **20 products**.

---

## Auth note for the mobile app

Email signup requires Auth to be enabled:

Dashboard → **Authentication** → **Providers** → enable **Email**

After a user registers, the `handle_new_user` trigger automatically creates rows in:
- `public.users`
- `public.user_preferences`

---

## What I cannot do from here

I cannot run migrations on your cloud Supabase project without either:

- you running `supabase db push` locally, or
- you pasting the SQL in the dashboard, or
- you providing database password / service role key for CLI access

The **anon key alone** is not enough to create tables.

---

## After migrations

1. Confirm mobile `.env` has:
   - `SUPABASE_URL=https://yactklxxcianiaymvloa.supabase.co`
   - `SUPABASE_ANON_KEY=...`
2. Run the Flutter app:
   ```bash
   cd apps/mobile
   flutter pub get
   flutter run
   ```
