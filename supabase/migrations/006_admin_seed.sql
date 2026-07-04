-- Run once in Supabase SQL Editor to create a default admin login
-- Password for dev login: admin123

insert into public.admin_users (email, password_hash, role)
values ('admin@dealdash.com.au', 'admin123', 'super_admin')
on conflict (email) do nothing;
