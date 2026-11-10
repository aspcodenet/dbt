with source as (
    select *
    from {{ source('ordersystem', 'orders') }}
),
columns_renamed as (
    select
        order_id as order_id,
        customer_id as customer_id,
        order_date as order_date,
        total_amount as total_amount,
        coalesce(status, 'unknown') as status,
        cast(total_amount * 100 as integer) as total_amount_in_cents
    from source
),
type_casts_applied as (
    select
        cast(order_id as int) as order_id,
        cast(customer_id as int) as customer_id,
        cast(order_date as date) as order_date,
        cast(total_amount as decimal(10, 2)) as total_amount,
        cast(status as varchar(50)) as status,
        cast(total_amount_in_cents as integer) as total_amount_in_cents
    from columns_renamed
)
select *
from type_casts_applied