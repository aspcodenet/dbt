with source as (
    select * 
    from {{ source('ordersystem', 'customers') }}
),

renamed_and_casted as (
    select
        -- Id:n
        cast(customer_id as integer) as customer_id,
        
        -- Text-fält
        cast(first_name as varchar(50)) as first_name,
        cast(last_name as varchar(50)) as last_name,
        
        -- Beräknad kolumn: Sammanslaget fullständigt namn
        cast(first_name || ' ' || last_name as varchar(105)) as full_name,
        
        -- Text-tvätt & NULL-hantering för e-post
        cast(lower(coalesce(email, 'missing@example.com')) as varchar(100)) as email,
        
        -- Tidsstämpel / Datum för när kunden skapades
        cast(created_at as timestamp) as created_at
        
    from source
)

select * 
from renamed_and_casted