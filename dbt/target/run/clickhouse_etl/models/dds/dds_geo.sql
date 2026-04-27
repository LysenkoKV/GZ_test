
        
  
    
    
    
        
        insert into `dds`.`dim_geo`
        ("click_id", "geo_latitude", "geo_longitude", "geo_country", "geo_timezone", "geo_region_name", "ip_address", "__ods_load_time", "__dds_load_time", "__kafka_offset")







SELECT
    click_id,
    geo_latitude,
    geo_longitude,
    geo_country,
    geo_timezone,
    geo_region_name,
    ip_address,
    ods_load_time AS __ods_load_time,
    now() AS __dds_load_time,
    kafka_offset AS __kafka_offset
FROM `ods`.`geo_data`
WHERE 1 = 1

  
  
    