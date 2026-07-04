create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.update_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger update_products_updated_at
  before update on public.products
  for each row execute procedure public.update_updated_at();

create trigger update_users_updated_at
  before update on public.users
  for each row execute procedure public.update_updated_at();
