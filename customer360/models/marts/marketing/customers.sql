{% set v_unique_key_column_name = 'cutomer_sk' %}
{% set v_business_key = ["id","category"] %}

{{
    config(
        materialized='table',
        tags = ["customer_data","postgres"],
        database= target.dbname,
        dataset= target.schema,
        alias='customers',
    )
}}


SELECT
    {{ dbt_utils.generate_surrogate_key(v_business_key) }} AS {{v_unique_key_column_name}},
    id as customer_id,
    gender,
    category,
    {{ age_in_years('birth_date', model.tags) }} AS age,
    MIN(transaction_date) AS first_purchase_date,
    MAX(transaction_date) AS last_purchase_date,
    SUM(amount) as total_expense
    FROM {{ ref('contacts_joined_with_transactions') }}
    GROUP BY id,gender,category,birth_date