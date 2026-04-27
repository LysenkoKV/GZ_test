{% set execution_id = invocation_id %}

{% set log_query_start %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'ods.device_data', 'incremental_load', now(), 'start')
{% endset %}

{% set log_query_end %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'ods.device_data', 'incremental_load', now(), 'end')
{% endset %}

{{
    config(
        materialized='incremental',
        schema='ods',
        alias='device_data',
        engine='ReplacingMergeTree(ods_load_time)',
        order_by='(click_id)',
        pre_hook= [log_query_start],
        post_hook=[log_query_end]
    )
}}

SELECT
    CAST(JSONExtractString(message, 'click_id') AS UUID) AS click_id,
    CAST(JSONExtractString(message, 'os') AS String) AS os,
    CAST(JSONExtractString(message, 'os_name') AS String) AS os_name,
    CAST(JSONExtractString(message, 'os_timezone') AS String) AS os_timezone,
    CAST(JSONExtractString(message, 'device_type') AS String) AS device_type,
    CAST(JSONExtractString(message, 'device_is_mobile') AS Bool) AS device_is_mobile,
    CAST(JSONExtractString(message, 'user_custom_id') AS String) AS user_custom_id,
    CAST(JSONExtractString(message, 'user_domain_id') AS UUID) AS user_domain_id,
    offset AS kafka_offset,
    partition AS kafka_partition,
    timestamp_kafka AS kafka_timestamp,
    load_time AS raw_load_time,
    now() AS ods_load_time
FROM  {{ source('raw', 'device_data') }}
WHERE
    isValidJSON(message) = 1
    AND JSONExtractString(message, 'click_id') != ''
{% if is_incremental() %}
    AND offset > (SELECT max(kafka_offset) FROM {{ this }})
{% endif %}


-- Проблемы:
-- 1. Могут быть старые данные с большим временем (часовые пояса)
-- 2. В Kafka время может идти не монотонно
-- 3. При перезагрузке старых данных они не попадут
-- Преимущества:
-- 1. offset строго монотонно возрастает в рамках партиции
-- 2. Не зависит от времени
-- 3. Гарантирует, что каждое сообщение обработается ровно один раз

