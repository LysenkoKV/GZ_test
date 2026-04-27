{% set execution_id = invocation_id %}

{% set log_query_start %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'dds.fct_click', 'incremental_load', now(), 'start')
{% endset %}

{% set log_query_end %}
    INSERT INTO log.ETL_LOG (log_id, table_name, operation, operation_time, status)
    VALUES (toUUID('{{ execution_id }}'), 'dds.fct_click', 'incremental_load', now(), 'end')
{% endset %}

{{
    config(
        materialized='incremental',
        schema='dds',
        alias='fct_click',
        engine='ReplacingMergeTree(__dds_load_time)',
        order_by='(click_id, event_id)',
        pre_hook= [log_query_start],
        post_hook=[log_query_end]
    )
}}

WITH PreClicks AS (
    SELECT
        click_id,
        kafka_offset AS __browser_kafka_offset,
        0 AS __device_kafka_offset,
        0 AS __geo_kafka_offset
        FROM {{ref('ods_browser')}}
        WHERE 1 = 1
        {% if is_incremental() %}
            AND kafka_offset > (SELECT max(__browser_kafka_offset) FROM {{ this }})
        {% endif %}

    UNION ALL

    SELECT
        click_id,
        0 AS __browser_kafka_offset,
        kafka_offset AS __device_kafka_offset,
        0 AS __geo_kafka_offset
        FROM {{ref('ods_device')}}
        WHERE 1 = 1
        {% if is_incremental() %}
            AND kafka_offset > (SELECT max(__device_kafka_offset) FROM {{ this }})
        {% endif %}

    UNION ALL

    SELECT
        click_id,
        0 AS __browser_kafka_offset,
        0 AS __device_kafka_offset,
        kafka_offset AS __geo_kafka_offset
        FROM {{ref('ods_geo')}}
        WHERE 1 = 1
        {% if is_incremental() %}
            AND kafka_offset > (SELECT max(__geo_kafka_offset) FROM {{ this }})
        {% endif %}
),

Clicks AS (
    SELECT 
        click_id,
        MAX(__browser_kafka_offset) AS __browser_kafka_offset,
        MAX(__device_kafka_offset) AS __device_kafka_offset,
        MAX(__geo_kafka_offset) AS __geo_kafka_offset
    FROM PreClicks
    GROUP BY
        click_id
)


SELECT
    fct.click_id,
    br.event_id,
    br.event_timestamp,
    1 AS cnt,
    now() AS __dds_load_time,
    fct.__browser_kafka_offset,
    fct.__device_kafka_offset,
    fct.__geo_kafka_offset
FROM Clicks AS fct
LEFT JOIN {{ref('ods_browser')}} AS br ON fct.click_id = br.click_id