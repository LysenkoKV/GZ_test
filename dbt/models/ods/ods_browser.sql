{% set execution_id = invocation_id %}

{% set log_query_start %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'ods.browser_data', 'incremental_load', now(), 'start')
{% endset %}

{% set log_query_end %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'ods.browser_data', 'incremental_load', now(), 'end')
{% endset %}

{{
    config(
        materialized='incremental',
        schema='ods',
        alias='browser_data',
        engine='ReplacingMergeTree(ods_load_time)',
        order_by='(click_id, event_id)',
        pre_hook= [log_query_start],
        post_hook=[log_query_end]
    )
}}

SELECT
    CAST(JSONExtractString(message, 'event_id') AS UUID) AS event_id,
    CAST(JSONExtractString(message, 'event_timestamp') AS DateTime64(6, 'Europe/Moscow')) AS event_timestamp,
    CAST(JSONExtractString(message, 'event_type') AS String) AS event_type,
    CAST(JSONExtractString(message, 'click_id') AS UUID) AS click_id,
    CAST(JSONExtractString(message, 'browser_name') AS String) AS browser_name,
    CAST(JSONExtractString(message, 'browser_user_agent') AS String) AS browser_user_agent,
    CAST(JSONExtractString(message, 'browser_language') AS String) AS browser_language,
    offset AS kafka_offset,
    partition AS kafka_partition,
    timestamp_kafka AS kafka_timestamp,
    load_time AS raw_load_time,
    now() AS ods_load_time
FROM  {{ source('raw', 'browser_data') }}
WHERE
    isValidJSON(message) = 1
    AND JSONExtractString(message, 'event_id') != ''
{% if is_incremental() %}
    AND offset > (SELECT max(kafka_offset) FROM {{ this }})
{% endif %}