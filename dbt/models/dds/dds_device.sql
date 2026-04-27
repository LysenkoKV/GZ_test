{% set execution_id = invocation_id %}

{% set log_query_start %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'dds.dim_device', 'incremental_load', now(), 'start')
{% endset %}

{% set log_query_end %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'dds.dim_device', 'incremental_load', now(), 'end')
{% endset %}

{{
    config(
        materialized='incremental',
        schema='dds',
        alias='dim_device',
        engine='ReplacingMergeTree(__dds_load_time)',
        order_by='(click_id)',
        pre_hook= [log_query_start],
        post_hook=[log_query_end]
    )
}}

SELECT
    click_id,
    os,
    os_name,
    os_timezone,
    device_type,
    device_is_mobile,
    user_custom_id,
    user_domain_id,
    ods_load_time AS __ods_load_time,
    now() AS __dds_load_time,
    kafka_offset AS __kafka_offset
FROM {{ref('ods_device')}}
WHERE 1 = 1
{% if is_incremental() %}
    AND kafka_offset > (SELECT max(__kafka_offset) FROM {{ this }})
{% endif %}
