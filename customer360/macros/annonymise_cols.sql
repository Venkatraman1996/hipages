{#- Future enhancement to add salt, shuffle, spl character encoding , etc... -#}

{%- macro annonymise_cols(item) -%}
       {%- if item['hash_type'] == 'full_hash' -%}
           {{item['enc_type']}}(concat({{ item['column_name'] }})) AS {{item['alias']}} 
       {%- elif item['hash_type'] == 'hash_email' -%}
           concat({{item['enc_type']}}(split_part({{item['column_name']}},'@',1)),'@',split_part({{item['column_name']}},'@',2)) AS {{item['alias']}} 
       {%- elif item['hash_type'] == 'mask_uname' -%}
         {#- random names can be made to be picked from available name bucket in DB -#}
           'fname.lname' AS {{item['alias']}} 
       {%- elif item['hash_type'] == 'ext_state' -%}
        {#-  address format expected "100 JohnWick Turn, East Matthewtown, QLD, 2633" -#}
           CONCAT(trim(split_part(UPPER({{item['column_name']}}),',',-2)),'|',trim(split_part(UPPER({{item['column_name']}}),',',-1))) AS {{item['alias']}} ,
           trim(split_part(UPPER({{item['column_name']}}),',',-2)) AS State
       {%- else -%}    
            {{item['enc_type']}}(concat({{ item['column_name'] }})) AS {{item['alias']}}
       {%- endif -%}
{%- endmacro -%}