-- Faktatabell: en rad per order. Fk: customer_id -> dim_customers.
select
    order_id,
    customer_id,
    order_date,
    status,
    total_amount,
    total_amount_in_cents
from {{ ref('stg_ordersystem_orders') }}
