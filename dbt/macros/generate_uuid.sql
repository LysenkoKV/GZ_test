{% macro generate_uuid() %}
    {% set query %}
        SELECT generateUUIDv4()
    {% endset %}
    {% set result = run_query(query) %}
    {% if result %}
        {% set uuid = result.rows[0][0] %}
        {% do log('Generated UUID: ' ~ uuid, info=True) %}
        {{ return(uuid) }}
    {% else %}
        {{ return('00000000-0000-0000-0000-000000000000') }}
    {% endif %}
{% endmacro %}