








SELECT
    event_id,
    page_url,
    page_url_path,
    referer_url,
    referer_medium,
    utm_medium,
    utm_source,
    utm_content,
    utm_campaign,
    ods_load_time AS __ods_load_time,
    now() AS __dds_load_time,
    kafka_offset AS __kafka_offset
FROM `ods`.`location_data`
WHERE 1 = 1
