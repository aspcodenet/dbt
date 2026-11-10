-- ============================================================================
-- INTERMEDIATE-LAGER
--
-- Här bor logik som är för affärsnära för staging, men som flera marts kan
-- behöva återanvända: joins mellan staging-modeller och beräkningar som bygger
-- på dem. Till skillnad från staging är raden inte längre 1:1 mot en källtabell.
--
-- Tumregel: staging = "vad sa källan?", intermediate = "vad betyder det?",
-- marts = "vad ska rapporten visa?". Modellen materialiseras som view så att
-- den går att inspektera direkt i databasen (till skillnad från ephemeral).
--
-- Korn: en rad per orderrad (order_item_id).
-- Används av: fct_order_items.
-- ============================================================================
with order_items as (
    select *
    from {{ ref('stg_ordersystem_order_items') }}
),

orders as (
    select
        order_id,
        customer_id,
        order_date,
        status
    from {{ ref('stg_ordersystem_orders') }}
),

products as (
    select
        product_id,
        product_name,
        category,
        list_price
    from {{ ref('stg_ordersystem_products') }}
)

select
    -- Nycklar och korn
    oi.order_item_id,
    oi.order_id,
    o.customer_id,
    oi.product_id,

    -- Orderattribut
    o.order_date,
    o.status,

    -- Produktattribut: behövs för rabattberäkningen nedan
    p.product_name,
    p.category,
    p.list_price,

    -- Mått som redan räknats fram i staging
    oi.quantity,
    oi.unit_price,
    oi.line_amount,
    oi.line_amount_in_cents,

    -- Rabatt mot listpris för hela raden (0 om raden såldes till listpris)
    cast(
        (coalesce(p.list_price, oi.unit_price) - oi.unit_price) * oi.quantity
        as decimal(10, 2)
    ) as discount_amount

from order_items as oi
inner join orders as o
    on oi.order_id = o.order_id
-- left join: en orderrad ska inte tappas bara för att produkten är okänd
left join products as p
    on oi.product_id = p.product_id
