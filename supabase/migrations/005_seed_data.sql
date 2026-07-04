insert into public.retailers (name, slug, website_url, scrape_url, scrape_frequency) values
('Woolworths', 'woolworths', 'https://www.woolworths.com.au', 'https://www.woolworths.com.au/shop/catalogue', 'daily'),
('Coles', 'coles', 'https://www.coles.com.au', 'https://www.coles.com.au/on-special', 'daily'),
('Aldi', 'aldi', 'https://www.aldi.com.au', 'https://www.aldi.com.au/en/special-buys/', 'twice_weekly'),
('Chemist Warehouse', 'chemist-warehouse', 'https://www.chemistwarehouse.com.au', 'https://www.chemistwarehouse.com.au/specials', 'daily'),
('Priceline', 'priceline', 'https://www.priceline.com.au', 'https://www.priceline.com.au/offers', 'daily'),
('Kmart', 'kmart', 'https://www.kmart.com.au', 'https://www.kmart.com.au/sale', 'daily'),
('BIG W', 'bigw', 'https://www.bigw.com.au', 'https://www.bigw.com.au/category/sale', 'daily'),
('Target Australia', 'target-au', 'https://www.target.com.au', 'https://www.target.com.au/sale', 'daily'),
('Bunnings', 'bunnings', 'https://www.bunnings.com.au', 'https://www.bunnings.com.au/specials', 'daily'),
('Officeworks', 'officeworks', 'https://www.officeworks.com.au', 'https://www.officeworks.com.au/information/catalogues-offers', 'daily'),
('JB Hi-Fi', 'jbhifi', 'https://www.jbhifi.com.au', 'https://www.jbhifi.com.au/pages/sale', 'daily'),
('Harvey Norman', 'harvey-norman', 'https://www.harveynorman.com.au', 'https://www.harveynorman.com.au/catalogues-specials', 'daily'),
('Petbarn', 'petbarn', 'https://www.petbarn.com.au', 'https://www.petbarn.com.au/sale', 'daily'),
('Costco Australia', 'costco-au', 'https://www.costco.com.au', 'https://www.costco.com.au/Savings', 'weekly'),
('IKEA Australia', 'ikea-au', 'https://www.ikea.com/au/en', 'https://www.ikea.com/au/en/offers/', 'weekly');

with root_categories as (
  insert into public.categories (name, slug, icon_name, display_order) values
  ('Grocery', 'grocery', 'local_grocery_store', 1),
  ('Household', 'household', 'cleaning_services', 2),
  ('Personal Care', 'personal-care', 'spa', 3),
  ('Baby Products', 'baby-products', 'child_care', 4),
  ('Medicines', 'medicines', 'medication', 5),
  ('Electronics', 'electronics', 'devices', 6),
  ('Garden', 'garden', 'grass', 7),
  ('Hardware', 'hardware', 'handyman', 8)
  on conflict (slug) do update set name = excluded.name
  returning id, slug
)
insert into public.categories (name, slug, parent_id, icon_name, display_order)
select 'Coffee & Tea', 'coffee-tea', id, 'coffee', 10 from root_categories where slug = 'grocery'
union all
select 'Snacks', 'snacks', id, 'cookie', 11 from root_categories where slug = 'grocery'
union all
select 'Dishwashing', 'dishwashing', id, 'local_drink', 20 from root_categories where slug = 'household'
union all
select 'Toilet Paper', 'toilet-paper', id, 'receipt_long', 21 from root_categories where slug = 'household'
union all
select 'Oral Care', 'oral-care', id, 'mood', 30 from root_categories where slug = 'personal-care'
union all
select 'Skin Care', 'skin-care', id, 'face', 31 from root_categories where slug = 'personal-care'
union all
select 'Nappies', 'nappies', id, 'child_friendly', 40 from root_categories where slug = 'baby-products'
union all
select 'Baby Formula', 'baby-formula', id, 'emoji_food_beverage', 41 from root_categories where slug = 'baby-products'
union all
select 'Pain Relief', 'pain-relief', id, 'healing', 50 from root_categories where slug = 'medicines'
union all
select 'Vitamins', 'vitamins', id, 'health_and_safety', 51 from root_categories where slug = 'medicines'
union all
select 'TV & Audio', 'tv-audio', id, 'tv', 60 from root_categories where slug = 'electronics'
union all
select 'Computing', 'computing', id, 'laptop', 61 from root_categories where slug = 'electronics'
union all
select 'Outdoor Power', 'outdoor-power', id, 'agriculture', 70 from root_categories where slug = 'garden'
union all
select 'Garden Care', 'garden-care', id, 'yard', 71 from root_categories where slug = 'garden'
union all
select 'Tools', 'tools', id, 'construction', 80 from root_categories where slug = 'hardware'
union all
select 'Storage', 'storage', id, 'inventory_2', 81 from root_categories where slug = 'hardware'
on conflict (slug) do nothing;

insert into public.products (name, brand, category_id, barcode, image_url)
select p.name, p.brand, c.id, p.barcode, p.image_url
from (
  values
  ('Quilton 3 Ply Toilet Tissue 24 Pack', 'Quilton', 'toilet-paper', '9300633354771', null),
  ('Colgate Total Advanced Toothpaste 200g', 'Colgate', 'oral-care', '9300673882166', null),
  ('Huggies Ultra Dry Nappies Toddler 58 Pack', 'Huggies', 'nappies', '9300607354622', null),
  ('Nescafe Blend 43 Instant Coffee 500g', 'Nescafe', 'coffee-tea', '7613032144508', null),
  ('Finish Quantum Ultimate Dishwasher Tablets 60pk', 'Finish', 'dishwashing', '9300701659876', null),
  ('Panadol Rapid Caplets 96 Pack', 'Panadol', 'pain-relief', '9300657001231', null),
  ('Blackmores Vitamin C 500mg 200 Tablets', 'Blackmores', 'vitamins', '9300807329012', null),
  ('Aptamil Gold+ Toddler Milk Drink Stage 3 900g', 'Aptamil', 'baby-formula', '8716900573312', null),
  ('Smiths Original Crinkle Cut Chips 170g', 'Smiths', 'snacks', '9300603120047', null),
  ('Kleenex Viva Paper Towel 6 Pack', 'Kleenex', 'household', '9310088000401', null),
  ('Sukin Hydrating Mist Toner 125ml', 'Sukin', 'skin-care', '9327693001028', null),
  ('Oral-B Pro Expert Soft Toothbrush 4 Pack', 'Oral-B', 'oral-care', '8001090783300', null),
  ('Samsung 55-inch 4K UHD Smart TV', 'Samsung', 'tv-audio', null, null),
  ('Sony WH-1000XM5 Wireless Headphones', 'Sony', 'tv-audio', null, null),
  ('Apple iPad 10th Gen 64GB Wi-Fi', 'Apple', 'computing', null, null),
  ('HP Pavilion 15.6-inch Laptop', 'HP', 'computing', null, null),
  ('Ryobi 18V Cordless Drill Driver Kit', 'Ryobi', 'tools', null, null),
  ('Ozito 1800W Electric Lawn Mower', 'Ozito', 'outdoor-power', null, null),
  ('Scotts Lawn Builder All Purpose Fertiliser 4kg', 'Scotts', 'garden-care', null, null),
  ('Whites Storage Crate 52L', 'Whites', 'storage', null, null)
) as p(name, brand, category_slug, barcode, image_url)
join public.categories c on c.slug = p.category_slug
on conflict (barcode) do nothing;
