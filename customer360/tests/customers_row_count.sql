with conform_active_records as (
    SELECT count(*) AS active_records 
    FROM
    (SELECT
        distinct id, category
    FROM {{ source('stg_tables','contacts_joined_with_transactions') }}) alias
),
fact_records as (
    SELECT 
        COUNT(cutomer_sk) as active_records
    FROM {{ref('customers')}} as active_record_count
),
final as (
    SELECT (SELECT active_records FROM conform_active_records) - (SELECT active_records FROM fact_records) as diff_count 
)

SELECT diff_count 
FROM final 
WHERE diff_count != 0