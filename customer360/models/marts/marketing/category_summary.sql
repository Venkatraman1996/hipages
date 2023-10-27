{% set v_unique_key_column_name = 'category_sk' %}
{% set v_business_key = ["category"] %}
{{
    config(
        materialized='table',
        tags = ["customer_data","postgres"],
        database= target.dbname,
        dataset= target.schema,
        alias='category_summary',
    )
}}

WITH category_summary AS (
    SELECT
    {{ dbt_utils.generate_surrogate_key(v_business_key) }} AS {{v_unique_key_column_name}},
    category,
    SUM(item_count) AS total_item_purchased,
    SUM(amount) AS total_revenue,
    RANK() OVER (PARTITION BY category ORDER BY SUM(amount) DESC) AS rank,
    LEAD(category) OVER (order by SUM(amount) DESC) as next_best_category
    FROM {{ ref('stg_web__transactions') }}
    GROUP BY 1,2
)

SELECT *
FROM category_summary