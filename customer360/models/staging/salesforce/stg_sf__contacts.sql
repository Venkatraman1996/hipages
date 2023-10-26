{% set v_unique_key_column_name = 'id' %}
{%- set schema =
      [   {'column_name': 'id', 'alias':'id' , 'hash_type':'no','enc_type':'no'},
          {'column_name': 'username', 'alias':'user_name' , 'hash_type':'full_hash','enc_type':'MD5'},          
          {'column_name': 'name', 'alias':'name' , 'hash_type':'mask_uname','enc_type':'MD5'}, 
          {'column_name': 'gender', 'alias':'gender' , 'hash_type':'no','enc_type':'no'}, 
          {'column_name': 'address', 'alias':'address' , 'hash_type':'ext_state','enc_type':'MD5'}, 
          {'column_name': 'mail', 'alias':'email_address' , 'hash_type':'hash_email','enc_type':'MD5'},          
          {'column_name': 'birthdate', 'alias':'birth_date' , 'hash_type':'no','enc_type':'no'}, 
          {'column_name': '_loaded_at_utc', 'alias':'_loaded_at_utc' , 'hash_type':'no','enc_type':'no'}
      ]
-%}

{{
    config(
        materialized='incremental',
        tags = ["customer_data","postgres"],
        database= target.dbname,
        dataset=target.schema,
        alias='stg_sf__contacts',
        unique_key = v_unique_key_column_name
    )
}}

with source as (
    select {% for item in schema %}
    {%- if item['hash_type'] == 'no' -%}
        {{item['column_name']}} AS {{item['alias']}} {% if not loop.last %},{% endif %}
    {% else -%}
        {{annonymise_cols(item)}} {% if not loop.last %},{% endif %}
    {% endif -%}
    {%- endfor -%}
from {{ ref('contacts') }}
    {% if is_incremental() %}
    where _loaded_at_utc > (select max(_loaded_at_utc) from {{ this }})
    {% endif %}
),

renamed as (
    select
        id,
        user_name,
        name,
        gender,
        address, 
        State,
        email_address,
        birth_date,
        _loaded_at_utc
    from source     
)

select * from renamed

