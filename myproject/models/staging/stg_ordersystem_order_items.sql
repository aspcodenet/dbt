with source as (
    select *
    from {{ source('ordersystem', 'order_items') }}
),

renamed_and_casted as (
    select
        -- Id:n och nycklar
        cast(order_item_id as integer) as order_item_id,
        cast(order_id as integer) as order_id,
        cast(product_id as varchar(50)) as product_id,

        -- Antal och styckpris
        cast(quantity as integer) as quantity,
        cast(unit_price as decimal(10, 2)) as unit_price,

        -- Beräknat radbelopp, i kronor och i ören
        cast(quantity * unit_price as decimal(10, 2)) as line_amount,
        cast(quantity * unit_price * 100 as integer) as line_amount_in_cents

    from source
)

select *
from renamed_and_casted
