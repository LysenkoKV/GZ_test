







WITH PreClicks AS (
    SELECT
        click_id,
        kafka_offset AS __browser_kafka_offset,
        0 AS __device_kafka_offset,
        0 AS __geo_kafka_offset
        FROM `ods`.`browser_data`
        WHERE 1 = 1
        

    UNION ALL

    SELECT
        click_id,
        0 AS __browser_kafka_offset,
        kafka_offset AS __device_kafka_offset,
        0 AS __geo_kafka_offset
        FROM `ods`.`device_data`
        WHERE 1 = 1
        

    UNION ALL

    SELECT
        click_id,
        0 AS __browser_kafka_offset,
        0 AS __device_kafka_offset,
        kafka_offset AS __geo_kafka_offset
        FROM `ods`.`geo_data`
        WHERE 1 = 1
        
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
LEFT JOIN `ods`.`browser_data` AS br ON fct.click_id = br.click_id