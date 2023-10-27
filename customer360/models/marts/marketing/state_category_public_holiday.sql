{{
    config(
        materialized='table',
        tags = ["customer_data","postgres"],
        database= target.dbname,
        dataset=target.schema,
    )
}}

WITH transactions AS (
    SELECT
    "state" AS contact_state,
    DATE(transaction_date) AS transaction_date,
    amount,
    item_count,
    category
    FROM {{ ref('contacts_joined_with_transactions') }}

),

join_cte AS (
    SELECT
    tr.transaction_date,
    tr.contact_state as contact_state,
    tr.category,
    tr.amount,
    tr.item_count,
    CASE WHEN ph."state" is null Then 'public_holiday' ELSE 'Regular' END AS public_holiday 
    FROM transactions tr
    LEFT JOIN {{ref('stg_sf__public_holidays')}} ph 
    ON ph."state" = tr.contact_state AND 
    ph."date" = tr.transaction_date)

SELECT 
contact_state,
category,
public_holiday,
SUM(amount) AS amount,
SUM(item_count) AS item_count
FROM join_cte
GROUP BY
contact_state,
category,
public_holiday
ORDER BY 1,2,3