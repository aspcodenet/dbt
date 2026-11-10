-- Faktatabell på radnivå: en rad per orderrad.
-- Ingen joinlogik här — den bor i int_order_items_enriched, så att fler marts
-- kan återanvända samma berikade rader.
-- Fk: order_id -> fct_orders, customer_id -> dim_customers, product_id -> dim_products.
select
    order_item_id,
    order_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    unit_price,
    line_amount,
    line_amount_in_cents,
    discount_amount
from {{ ref('int_order_items_enriched') }}
