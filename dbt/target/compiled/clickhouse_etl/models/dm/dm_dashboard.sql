







SELECT
    fct.event_timestamp AS event_timestamp,
    COALESCE(geo.geo_country, 'Неизвестно') AS geo_country,
    COALESCE(br.browser_name, 'Неизвестно') AS browser_name,
    CASE WHEN dv.device_is_mobile = true THEN 'Да'
         WHEN dv.device_is_mobile = false THEN 'Нет'
         ELSE 'Неизвестно' END  AS device_is_mobile,
    COALESCE(loc.utm_source, 'Неизвестно') AS utm_source,
    COALESCE(loc.utm_medium, 'Неизвестно') AS utm_medium,
    COALESCE(loc.utm_campaign, 'Неизвестно') AS utm_campaign,
    fct.click_id AS click_id,
    fct.event_id AS event_id,
    fct.__dds_load_time as __dds_load_time
FROM `dds`.`fct_click` AS fct
LEFT JOIN `dds`.`dim_geo` AS geo ON fct.click_id = geo.click_id
LEFT JOIN `dds`.`dim_browser` AS br ON fct.click_id = br.click_id AND fct.event_id = br.event_id
LEFT JOIN `dds`.`dim_device` AS dv ON fct.click_id = dv.click_id
LEFT JOIN `dds`.`dim_location` AS loc ON fct.event_id = loc.event_id
WHERE 1 = 1
