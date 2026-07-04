# DealDash Admin Portal

Next.js 14 admin dashboard at `apps/admin/`.

## Troubleshooting login

### "Server error" on login
1. Ensure `apps/admin/.env.local` exists with:
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://yactklxxcianiaymvloa.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=<your anon key>
   ```
2. Restart the dev server after creating/editing `.env.local`:
   ```bash
   npm run dev
   ```

### "Invalid credentials"
Run the admin seed in Supabase SQL Editor:
```sql
insert into public.admin_users (email, password_hash, role)
values ('admin@dealdash.com.au', 'admin123', 'super_admin')
on conflict (email) do nothing;
```

Also run `supabase/migrations/007_admin_users_rls.sql` so the anon key can read `admin_users` for login.

### Dashboard shows empty data
Add `SUPABASE_SERVICE_ROLE_KEY` to `.env.local` — the service role is required to read user tables protected by RLS.

## Setup

1. Copy env file:
   ```bash
   cp .env.example .env.local
   ```

2. Fill in:
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://yactklxxcianiaymvloa.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=<your anon key>
   SUPABASE_SERVICE_ROLE_KEY=<your service role key>
   ```

3. Create admin user (run in Supabase SQL Editor):
   ```sql
   -- see supabase/migrations/006_admin_seed.sql
   ```

4. Install and run:
   ```bash
   cd apps/admin
   npm install
   npm run dev
   ```

5. Open http://localhost:3001/login
   - Email: `admin@dealdash.com.au`
   - Password: `admin123`

## Pages

| Route | Description |
|-------|-------------|
| `/` | Dashboard — stats, revenue chart, scrape health |
| `/retailers` | Retailer list and scrape URLs |
| `/products` | Searchable product table |
| `/promotions` | Active promotions |
| `/users` | User list with subscription status |
| `/revenue` | MRR and revenue chart |
| `/notifications` | Send manual notifications |
| `/system` | DB row counts + scrape logs |

## Build

```bash
npm run build
```
