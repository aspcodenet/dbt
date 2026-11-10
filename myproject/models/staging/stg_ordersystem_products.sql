with source as (
    select * 
    from {{ source('ordersystem', 'products') }}
),

-- slår ihop renaming och casting i en CTE för att undvika onödiga mellanlager
renamed_and_casted as (
    select
        -- Id:n och text
        cast(product_id as varchar(50)) as product_id,
        cast(product_name as varchar(100)) as product_name,
        cast(category as varchar(50)) as category,
        
        -- Mått i originalenhet (Decimal)
        cast(list_price as decimal(10, 2)) as list_price,
        
        -- Beräknat mått i ören/cent (Heltal)
        cast(list_price * 100 as integer) as list_price_in_cents
        
    from source
)

select * 
from renamed_and_casted