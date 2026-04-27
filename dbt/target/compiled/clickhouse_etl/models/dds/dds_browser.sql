







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
FROM `ods`.`browser_data`
WHERE 1 = 1
