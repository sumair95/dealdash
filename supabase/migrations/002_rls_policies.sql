create index idx_price_history_retailer_product
  on public.price_history(retailer_product_id, scraped_at desc);
create index idx_price_history_active_discount
  on public.price_history(is_active, discount_pct desc) where is_active = true;
create index idx_watchlist_user on public.watchlist(user_id);
create index idx_watchlist_product on public.watchlist(product_id);
create index idx_products_barcode on public.products(barcode) where barcode is not null;
create index idx_products_name_search
  on public.products using gin(to_tsvector('english', name || ' ' || coalesce(brand, '')));
create index idx_notifications_user_unread
  on public.notifications(user_id, is_read) where is_read = false;
create index idx_search_logs_user on public.search_logs(user_id, searched_at desc);

alter table public.users enable row level security;
alter table public.user_preferences enable row level security;
alter table public.watchlist enable row level security;
alter table public.notifications enable row level security;
alter table public.search_logs enable row level security;
alter table public.subscriptions enable row level security;
alter table public.products enable row level security;
alter table public.retailers enable row level security;
alter table public.categories enable row level security;
alter table public.retailer_products enable row level security;
alter table public.price_history enable row level security;

create policy "Users can read own profile"
  on public.users for select using (auth.uid() = id);
create policy "Users can update own profile"
  on public.users for update using (auth.uid() = id);

create policy "Users can read own preferences"
  on public.user_preferences for select using (auth.uid() = user_id);
create policy "Users can update own preferences"
  on public.user_preferences for update using (auth.uid() = user_id);
create policy "Users can insert own preferences"
  on public.user_preferences for insert with check (auth.uid() = user_id);

create policy "Users can read own watchlist"
  on public.watchlist for select using (auth.uid() = user_id);
create policy "Users can insert to own watchlist"
  on public.watchlist for insert with check (auth.uid() = user_id);
create policy "Users can delete from own watchlist"
  on public.watchlist for delete using (auth.uid() = user_id);
create policy "Users can update own watchlist"
  on public.watchlist for update using (auth.uid() = user_id);

create policy "Users can read own notifications"
  on public.notifications for select using (auth.uid() = user_id);
create policy "Users can update own notifications"
  on public.notifications for update using (auth.uid() = user_id);

create policy "Users can read own search logs"
  on public.search_logs for select using (auth.uid() = user_id);
create policy "Users can read own subscriptions"
  on public.subscriptions for select using (auth.uid() = user_id);

create policy "Public read products" on public.products for select using (true);
create policy "Public read retailers" on public.retailers for select using (true);
create policy "Public read categories" on public.categories for select using (true);
create policy "Public read retailer_products" on public.retailer_products for select using (true);
create policy "Public read price_history" on public.price_history for select using (true);
