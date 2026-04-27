







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
FROM  `raw`.`browser_data`
WHERE
    isValidJSON(message) = 1
    AND JSONExtractString(message, 'event_id') != ''
