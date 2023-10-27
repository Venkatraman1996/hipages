{% set v_unique_key_column_name = 'id' %}

{{
    config(
        materialized='incremental',
        tags = ["customer_data","postgres"],
        database= target.dbname,
        dataset=target.schema,
        alias='stg_web__transactions',
        unique_key = v_unique_key_column_name
    )
}}

with source as (
    select * from {{ ref('transactions') }}
    {% if is_incremental() %}
    where _loaded_at_utc > (select max(_loaded_at_utc) from {{ this }})
    {% endif %}
),

renamed as (
    select
        id,
        contact_id,
        {{ as_timestamp_utc('transaction_date', model.tags) }} as transaction_date,
        amount,
        item_count,
        category, 
        _loaded_at_utc
    from source     
)

select * from renamed

