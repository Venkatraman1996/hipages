{% macro age_in_years(date_column, tags) %}
   {% if var('postgres_flag') in tags %}
     date_part('year', age(current_date, {{ date_column }}))
   {% endif %}
{% endmacro %}