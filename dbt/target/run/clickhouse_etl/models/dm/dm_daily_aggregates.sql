
        insert into `ods_dm`.`daily_aggregates`
        ("fct.click_id", "fct.event_id", "event_timestamp", "cnt", "fct.__dds_load_time", "__browser_kafka_offset", "__device_kafka_offset", "__geo_kafka_offset", "br.click_id", "br.event_id", "event_type", "browser_name", "browser_user_agent", "browser_language", "br.__ods_load_time", "br.__dds_load_time", "br.__kafka_offset", "dv.click_id", "os", "os_name", "os_timezone", "device_type", "device_is_mobile", "user_custom_id", "user_domain_id", "dv.__ods_load_time", "dv.__dds_load_time", "dv.__kafka_offset", "geo.click_id", "geo_latitude", "geo_longitude", "geo_country", "geo_timezone", "geo_region_name", "ip_address", "geo.__ods_load_time", "geo.__dds_load_time", "geo.__kafka_offset", "loc.event_id", "page_url", "page_url_path", "referer_url", "referer_medium", "utm_medium", "utm_source", "utm_content", "utm_campaign", "loc.__ods_load_time", "loc.__dds_load_time", "loc.__kafka_offset")-- Ежедневная агрегация для трендов


SELECT *
/*    toDate(fct.event_timestamp) as event_date,
    
    -- Измерения
    br.browser_name,
    dv.device_type,
    dv.device_is_mobile,
    geo.geo_country,
    loc.utm_source,
    loc.utm_medium,
    loc.utm_campaign,
    loc.page_url_path as landing_page
    
    -- Метрики
    COUNT(*) as total_events,
    COUNT(DISTINCT fct.click_id) as unique_users,
    COUNT(DISTINCT fct.event_id) as unique_events,
    COUNT(DISTINCT dv.user_custom_id) as unique_custom_ids,
    
    -- Поведенческие метрики
    COUNTIf(br.event_type = 'pageview') as pageviews,
    COUNTIf(loc.page_url_path = '/home') as homepage_views,
    COUNTIf(loc.page_url_path LIKE '/product%') as product_views,
    COUNTIf(loc.page_url_path = '/cart') as cart_views,
    COUNTIf(loc.page_url_path = '/payment') as payment_views,
    
    -- Конверсии (уникальные пользователи, дошедшие до этапа)
    COUNT(DISTINCT CASE WHEN loc.page_url_path = '/payment' THEN fct.click_id END) as users_reached_payment,
    
    -- Процентные метрики (можно посчитать в Power BI, но можно и здесь)
    -- Пользователи с корзиной / Все пользователи
    -- Пользователи с оплатой / Пользователи с корзиной
    
    -- UTM эффективность
    COUNT(DISTINCT CASE WHEN loc.utm_source IS NOT NULL THEN fct.click_id END) as users_from_campaign
    */
FROM `ods_dds`.`fct_click` fct
LEFT JOIN `ods_dds`.`dim_browser` br 
    ON fct.click_id = br.click_id AND fct.event_id = br.event_id
LEFT JOIN `ods_dds`.`dim_device` dv ON fct.click_id = dv.click_id
LEFT JOIN `ods_dds`.`dim_geo` geo ON fct.click_id = geo.click_id
LEFT JOIN `ods_dds`.`dim_location` loc ON fct.event_id = loc.event_id
/*GROUP BY 
    event_date, 
    br.browser_name,
    dv.device_type,
    dv.device_is_mobile,
    geo.geo_country,
    loc.utm_source,
    loc.utm_medium,
    loc.utm_campaign,
    landing_page*/
  
    