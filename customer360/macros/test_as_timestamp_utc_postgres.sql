{% macro test_as_timestamp_utc_postgres() %}
    {% set query %}
    select  {{ as_timestamp_utc("'"+var("test_date")+"'","'"+var("postgres_flag")+"'") }} as col
    {% endset %}
    {% set results = run_query(query) %}
    {% if execute %}
    {% set v_bc_rows = results.columns[0].values()[0] %}
    {% endif %}
{% endmacro %}