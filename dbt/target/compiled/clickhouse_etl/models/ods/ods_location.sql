







SELECT
    CAST(JSONExtractString(message, 'event_id') AS UUID) AS event_id,
    CAST(JSONExtractString(message, 'page_url') AS String) AS page_url,
    CAST(JSONExtractString(message, 'page_url_path') AS String) AS page_url_path,
    CAST(JSONExtractString(message, 'referer_url') AS String) AS referer_url,
    CAST(JSONExtractString(message, 'referer_medium') AS String) AS referer_medium,
    CAST(JSONExtractString(message, 'utm_medium') AS String) AS utm_medium,
    CAST(JSONExtractString(message, 'utm_source') AS String) AS utm_source,
    CAST(JSONExtractString(message, 'utm_content') AS String) AS utm_content,
    CAST(JSONExtractString(message, 'utm_campaign') AS String) AS utm_campaign,
    offset AS kafka_offset,
    partition AS kafka_partition,
    timestamp_kafka AS kafka_timestamp,
    load_time AS raw_load_time,
    now() AS ods_load_time
FROM  `raw`.`location_data`
WHERE
    isValidJSON(message) = 1
    AND JSONExtractString(message, 'event_id') != ''
