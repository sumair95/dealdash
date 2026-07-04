-- Allow server-side admin login to read admin_users with anon key (login only).
-- Service role bypasses RLS; this policy helps if only anon key is configured.

alter table public.admin_users enable row level security;

drop policy if exists "Service role full access admin_users" on public.admin_users;
drop policy if exists "Allow login read admin_users by email" on public.admin_users;

create policy "Allow login read admin_users by email"
  on public.admin_users
  for select
  using (true);

-- No insert/update/delete for anon — admin management via SQL or service role only.
