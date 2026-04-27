{% set execution_id = invocation_id %}

{% set log_query_start %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'ods.geo_data', 'incremental_load', now(), 'start')
{% endset %}

{% set log_query_end %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'ods.geo_data', 'incremental_load', now(), 'end')
{% endset %}

{{
    config(
        materialized='incremental',
        schema='ods',
        alias='geo_data',
        engine='ReplacingMergeTree(ods_load_time)',
        order_by='(click_id)',
        pre_hook= [log_query_start],
        post_hook=[log_query_end]
    )
}}

SELECT
    CAST(JSONExtractString(message, 'click_id') AS UUID) AS click_id,
    CAST(JSONExtractString(message, 'geo_latitude') AS Decimal(8, 5)) AS geo_latitude,
    CAST(JSONExtractString(message, 'geo_longitude') AS  Decimal(8, 5)) AS geo_longitude,
    CAST(JSONExtractString(message, 'geo_country') AS FixedString(2)) AS geo_country,
    CAST(JSONExtractString(message, 'geo_timezone') AS String) AS geo_timezone,
    CAST(JSONExtractString(message, 'geo_region_name') AS String) AS geo_region_name,
    CAST(JSONExtractString(message, 'ip_address') AS IPv4) AS ip_address,
    offset AS kafka_offset,
    partition AS kafka_partition,
    timestamp_kafka AS kafka_timestamp,
    load_time AS raw_load_time,
    now() AS ods_load_time
FROM  {{ source('raw', 'geo_data') }}
WHERE
    isValidJSON(message) = 1
    AND JSONExtractString(message, 'click_id') != ''
{% if is_incremental() %}
    AND offset > (SELECT max(kafka_offset) FROM {{ this }})
{% endif %}