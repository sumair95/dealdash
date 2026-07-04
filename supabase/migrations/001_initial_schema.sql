create extension if not exists "uuid-ossp";

create table public.retailers (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  slug text unique not null,
  logo_url text,
  website_url text not null,
  affiliate_url_template text,
  scrape_url text not null,
  scrape_frequency text default 'daily',
  is_active boolean default true,
  last_scraped_at timestamptz,
  scrape_success_count integer default 0,
  scrape_error_count integer default 0,
  created_at timestamptz default now()
);

create table public.categories (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  slug text unique not null,
  parent_id uuid references public.categories(id),
  icon_name text,
  display_order integer default 0,
  is_active boolean default true
);

create table public.products (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  brand text,
  category_id uuid references public.categories(id),
  barcode text unique,
  description text,
  image_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.retailer_products (
  id uuid primary key default uuid_generate_v4(),
  product_id uuid references public.products(id) on delete cascade,
  retailer_id uuid references public.retailers(id) on delete cascade,
  retailer_sku text,
  product_url text not null,
  image_url text,
  is_available boolean default true,
  created_at timestamptz default now(),
  unique(product_id, retailer_id)
);

create table public.price_history (
  id uuid primary key default uuid_generate_v4(),
  retailer_product_id uuid references public.retailer_products(id) on delete cascade,
  regular_price numeric(10,2) not null,
  sale_price numeric(10,2) not null,
  discount_pct numeric(5,2) generated always as (
    round(((regular_price - sale_price) / regular_price * 100), 2)
  ) stored,
  promotion_type text check (promotion_type in (
    'weekly_special', 'clearance', 'bogo', 'multi_buy', 'catalogue', 'limited_time'
  )),
  promotion_notes text,
  promotion_ends_at timestamptz,
  is_active boolean default true,
  scraped_at timestamptz default now()
);

create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  full_name text,
  avatar_url text,
  auth_provider text default 'email',
  subscription_status text default 'free' check (
    subscription_status in ('free', 'premium', 'cancelled', 'past_due')
  ),
  stripe_customer_id text unique,
  stripe_subscription_id text,
  search_count integer default 0,
  fcm_token text,
  fcm_token_updated_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.user_preferences (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade unique,
  favourite_retailer_ids uuid[] default '{}',
  favourite_category_ids uuid[] default '{}',
  notify_price_drops boolean default true,
  notify_lowest_ever boolean default true,
  notify_ending_soon boolean default true,
  notify_weekly_digest boolean default true,
  notify_ai_recommendations boolean default true,
  max_notifications_per_day integer default 10,
  updated_at timestamptz default now()
);

create table public.watchlist (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  product_id uuid references public.products(id) on delete cascade,
  target_price numeric(10,2),
  notify_any_drop boolean default true,
  created_at timestamptz default now(),
  unique(user_id, product_id)
);

create table public.notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  title text not null,
  body text not null,
  notification_type text,
  product_id uuid references public.products(id),
  retailer_id uuid references public.retailers(id),
  fcm_message_id text,
  sent_at timestamptz default now(),
  opened_at timestamptz,
  is_read boolean default false
);

create table public.search_logs (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  query text,
  result_count integer,
  searched_at timestamptz default now()
);

create table public.subscriptions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  stripe_subscription_id text unique not null,
  stripe_price_id text,
  status text,
  current_period_start timestamptz,
  current_period_end timestamptz,
  cancel_at_period_end boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.admin_users (
  id uuid primary key default uuid_generate_v4(),
  email text unique not null,
  password_hash text not null,
  role text default 'viewer' check (
    role in ('super_admin', 'content_manager', 'support', 'viewer')
  ),
  created_at timestamptz default now()
);

create table public.scrape_logs (
  id uuid primary key default uuid_generate_v4(),
  retailer_id uuid references public.retailers(id),
  started_at timestamptz default now(),
  completed_at timestamptz,
  products_found integer default 0,
  products_inserted integer default 0,
  products_updated integer default 0,
  error_message text,
  status text default 'running' check (status in ('running', 'success', 'partial', 'failed'))
);

create table public.deal_cache (
  id uuid primary key default uuid_generate_v4(),
  ranked_at timestamptz not null default now(),
  deals jsonb not null
);
