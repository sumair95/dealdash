create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, email, full_name, avatar_url, auth_provider)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data->>'avatar_url',
    coalesce(new.raw_user_meta_data->>'provider', 'email')
  );

  insert into public.user_preferences (user_id) values (new.id);
  return new;
end;
$$;

create or replace function public.increment_search_count(p_user_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  update public.users
  set search_count = search_count + 1
  where id = p_user_id;
end;
$$;

create or replace function public.get_today_deals(p_limit integer default 50)
returns table (
  product_id uuid,
  product_name text,
  brand text,
  image_url text,
  retailer_id uuid,
  retailer_name text,
  retailer_logo text,
  regular_price numeric,
  sale_price numeric,
  discount_pct numeric,
  promotion_type text,
  promotion_ends_at timestamptz,
  product_url text
)
language sql
stable
as $$
  select
    p.id as product_id,
    p.name as product_name,
    p.brand,
    coalesce(rp.image_url, p.image_url) as image_url,
    r.id as retailer_id,
    r.name as retailer_name,
    r.logo_url as retailer_logo,
    ph.regular_price,
    ph.sale_price,
    ph.discount_pct,
    ph.promotion_type,
    ph.promotion_ends_at,
    rp.product_url
  from public.price_history ph
  join public.retailer_products rp on ph.retailer_product_id = rp.id
  join public.products p on rp.product_id = p.id
  join public.retailers r on rp.retailer_id = r.id
  where ph.is_active = true
    and ph.scraped_at > now() - interval '24 hours'
    and r.is_active = true
  order by ph.discount_pct desc
  limit p_limit;
$$;

create or replace function public.search_products(
  p_query text,
  p_category_id uuid default null,
  p_retailer_id uuid default null,
  p_min_discount numeric default null,
  p_max_price numeric default null,
  p_limit integer default 20,
  p_offset integer default 0
)
returns table (
  product_id uuid,
  product_name text,
  brand text,
  image_url text,
  best_price numeric,
  best_retailer_name text,
  best_discount_pct numeric,
  retailer_count integer
)
language sql
stable
as $$
  select
    p.id as product_id,
    p.name as product_name,
    p.brand,
    p.image_url,
    min(ph.sale_price) as best_price,
    (
      select r2.name
      from public.retailers r2
      join public.retailer_products rp2 on r2.id = rp2.retailer_id
      join public.price_history ph2 on rp2.id = ph2.retailer_product_id
      where rp2.product_id = p.id and ph2.is_active = true
      order by ph2.sale_price asc
      limit 1
    ) as best_retailer_name,
    max(ph.discount_pct) as best_discount_pct,
    count(distinct rp.retailer_id)::integer as retailer_count
  from public.products p
  join public.retailer_products rp on p.id = rp.product_id
  join public.price_history ph on rp.id = ph.retailer_product_id
  where ph.is_active = true
    and (
      p_query is null
      or to_tsvector('english', p.name || ' ' || coalesce(p.brand, ''))
         @@ plainto_tsquery('english', p_query)
    )
    and (p_category_id is null or p.category_id = p_category_id)
    and (p_retailer_id is null or rp.retailer_id = p_retailer_id)
    and (p_min_discount is null or ph.discount_pct >= p_min_discount)
    and (p_max_price is null or ph.sale_price <= p_max_price)
  group by p.id, p.name, p.brand, p.image_url
  order by best_discount_pct desc
  limit p_limit offset p_offset;
$$;
