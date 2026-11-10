-- ============================================================================
-- Setup av rådata för dbt-projektet (source: ordersystem -> schema: raw)
-- Körs mot databasen dbtdemo:  psql -d dbtdemo -f scripts/setup_raw.sql
-- Scriptet är idempotent och kan köras flera gånger utan dubbletter.
-- ============================================================================

create schema if not exists raw;

-- ---------------------------------------------------------------------------
-- Tabeller
-- ---------------------------------------------------------------------------
create table if not exists raw.customers (
    customer_id integer primary key,
    first_name  varchar(50),
    last_name   varchar(50),
    email       varchar(100),
    created_at  timestamp
);

create table if not exists raw.products (
    product_id   varchar(50) primary key,
    product_name varchar(100),
    category     varchar(50),
    list_price   decimal(10, 2)
);

create table if not exists raw.orders (
    order_id     integer primary key,
    customer_id  integer references raw.customers (customer_id),
    order_date   date,
    total_amount decimal(10, 2),
    status       varchar(50)
);

create table if not exists raw.order_items (
    order_item_id integer primary key,
    order_id      integer references raw.orders (order_id),
    product_id    varchar(50) references raw.products (product_id),
    quantity      integer,
    unit_price    decimal(10, 2)
);

-- ---------------------------------------------------------------------------
-- Demodata: kunder
-- (kund 5 saknar e-post och kund 6 har skiftande versaler -> testar coalesce/lower)
-- ---------------------------------------------------------------------------
insert into raw.customers (customer_id, first_name, last_name, email, created_at)
values
    (1, 'Anna',   'Andersson', 'anna.andersson@example.com',  '2024-01-05 09:15:00'),
    (2, 'Bjorn',  'Berg',      'bjorn.berg@example.com',      '2024-01-12 13:40:00'),
    (3, 'Cecilia','Carlsson',  'cecilia.carlsson@example.com','2024-02-03 08:05:00'),
    (4, 'David',  'Dahl',      'david.dahl@example.com',      '2024-02-21 17:30:00'),
    (5, 'Elin',   'Eriksson',  null,                          '2024-03-02 11:00:00'),
    (6, 'Farid',  'Hassan',    'Farid.Hassan@Example.COM',    '2024-03-19 20:45:00')
on conflict (customer_id) do nothing;

-- ---------------------------------------------------------------------------
-- Demodata: produkter
-- ---------------------------------------------------------------------------
insert into raw.products (product_id, product_name, category, list_price)
values
    ('P-100', 'Kaffebryggare Classic', 'Kok',        499.00),
    ('P-101', 'Vattenkokare 1.7L',     'Kok',        249.50),
    ('P-102', 'Bordsset 4 personer',   'Hushall',    899.00),
    ('P-103', 'Tradlos mus',           'Elektronik', 199.00),
    ('P-104', 'Mekaniskt tangentbord', 'Elektronik', 1290.00),
    ('P-105', 'Lampan Nova',           'Belysning',  349.95)
on conflict (product_id) do nothing;

-- ---------------------------------------------------------------------------
-- Demodata: ordrar
-- (order 8 saknar status -> testar coalesce(status, 'unknown'))
-- ---------------------------------------------------------------------------
insert into raw.orders (order_id, customer_id, order_date, total_amount, status)
values
    (1001, 1, '2024-03-01',  499.00, 'completed'),
    (1002, 1, '2024-03-08',  249.50, 'completed'),
    (1003, 2, '2024-03-11',  899.00, 'shipped'),
    (1004, 3, '2024-03-15', 1290.00, 'completed'),
    (1005, 4, '2024-03-22',  199.00, 'pending'),
    (1006, 4, '2024-04-02',  599.90, 'cancelled'),
    (1007, 6, '2024-04-09', 1539.50, 'shipped'),
    (1008, 5, '2024-04-14',  349.95, null)
on conflict (order_id) do nothing;

-- ---------------------------------------------------------------------------
-- Demodata: orderrader
-- Radsummorna är avsiktligt lika ordrarnas total_amount (quantity * unit_price).
-- Rad 6 (order 1006) är såld under listpris, så intermediate-modellen får en
-- rabatt att räkna på.
-- ---------------------------------------------------------------------------
insert into raw.order_items (order_item_id, order_id, product_id, quantity, unit_price)
values
    (1, 1001, 'P-100', 1, 499.00),
    (2, 1002, 'P-101', 1, 249.50),
    (3, 1003, 'P-102', 1, 899.00),
    (4, 1004, 'P-104', 1, 1290.00),
    (5, 1005, 'P-103', 1, 199.00),
    (6, 1006, 'P-105', 2, 299.95),
    (7, 1007, 'P-104', 1, 1290.00),
    (8, 1007, 'P-101', 1, 249.50),
    (9, 1008, 'P-105', 1, 349.95)
on conflict (order_item_id) do nothing;

-- ---------------------------------------------------------------------------
-- Snabbkontroll
-- ---------------------------------------------------------------------------
select 'customers' as tabell, count(*) as antal from raw.customers
union all
select 'products',            count(*) from raw.products
union all
select 'orders',              count(*) from raw.orders
union all
select 'order_items',         count(*) from raw.order_items;
