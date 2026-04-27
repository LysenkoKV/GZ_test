{% set execution_id = invocation_id %}

{% set log_query_start %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'dds.dim_browser', 'incremental_load', now(), 'start')
{% endset %}

{% set log_query_end %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'dds.dim_browser', 'incremental_load', now(), 'end')
{% endset %}

{{
    config(
        materialized='incremental',
        schema='dds',
        alias='dim_browser',
        engine='ReplacingMergeTree(__dds_load_time)',
        order_by='(click_id, event_id)',
        pre_hook= [log_query_start],
        post_hook=[log_query_end]
    )
}}

SELECT
    click_id,
    event_id,
    event_type,
    browser_name,
    browser_user_agent,
    browser_language,
    ods_load_time AS __ods_load_time,
    now() AS __dds_load_time,
    kafka_offset AS __kafka_offset
FROM {{ref('ods_browser')}}
WHERE 1 = 1
{% if is_incremental() %}
    AND kafka_offset > (SELECT max(__kafka_offset) FROM {{ this }})
{% endif %}

