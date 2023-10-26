{% set v_unique_key_column_name = 'transaction_id' %}

{{
    config(
        materialized='incremental',
        tags = ["customer_data","postgres"],
        database= target.dbname,
        dataset=target.schema,
        alias='contacts_joined_with_transactions',
        unique_key = v_unique_key_column_name
    )
}}

WITH transactions_raw as (
    SELECT 
        contacts.*,
        transactions.id as transaction_id,
        transactions.transaction_date,
        transactions.amount,
        transactions.item_count,
        transactions.category,
        transactions._loaded_at_utc as transaction_load_date
    FROM {{ ref('stg_web__transactions') }} as transactions
    LEFT JOIN {{ ref('stg_sf__contacts') }} as contacts ON contacts.id = transactions.contact_id
    {% if is_incremental() %}
    where transactions._loaded_at_utc > (select max(transaction_load_date) from {{ this }})
    {% endif %}
)

SELECT

*
FROM transactions_raw