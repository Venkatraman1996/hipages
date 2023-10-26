{% macro as_timestamp_utc(column_name,tags) %}
   {% if var('postgres_flag') in tags %}
    to_timestamp({{ column_name }},'YYYY-MM-DD HH24:MI:SS.MS') :: timestamp at TIME zone 'UTC'
   {% endif %}
{% endmacro %}