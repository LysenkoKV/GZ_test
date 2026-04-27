{% set execution_id = invocation_id %}

{% set log_query_start %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'dds.dim_geo', 'incremental_load', now(), 'start')
{% endset %}

{% set log_query_end %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'dds.dim_geo', 'incremental_load', now(), 'end')
{% endset %}

{{
    config(
        materialized='incremental',
        schema='dds',
        alias='dim_geo',
        engine='ReplacingMergeTree(__dds_load_time)',
        order_by='(click_id)',
        pre_hook= [log_query_start],
        post_hook=[log_query_end]
    )
}}

SELECT
    click_id,
    geo_latitude,
    geo_longitude,
    geo_country,
    geo_timezone,
    geo_region_name,
    ip_address,
    ods_load_time AS __ods_load_time,
    now() AS __dds_load_time,
    kafka_offset AS __kafka_offset
FROM {{ref('ods_geo')}}
WHERE 1 = 1
{% if is_incremental() %}
    AND kafka_offset > (SELECT max(__kafka_offset) FROM {{ this }})
{% endif %}
