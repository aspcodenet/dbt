-- Dimension: en rad per kund. Naturlig nyckel: customer_id.
select
    customer_id,
    first_name,
    last_name,
    full_name,
    email,
    created_at
from {{ ref('stg_ordersystem_customers') }}
