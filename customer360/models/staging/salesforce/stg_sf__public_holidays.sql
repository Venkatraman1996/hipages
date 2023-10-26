{{
    config(
        materialized='table',
        tags = ["customer_data","postgres"],
        database= target.dbname,
        dataset= target.schema,
    )
}}


SELECT  Date("Date":: TEXT) AS date,
        "Holiday_Name",
        "State" as state
        from {{ ref('australian_public_holidays') }}
