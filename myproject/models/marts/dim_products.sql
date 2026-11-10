-- Dimension: en rad per produkt. Naturlig nyckel: product_id.
select
    product_id,
    product_name,
    category,
    list_price,
    list_price_in_cents
from {{ ref('stg_ordersystem_products') }}
