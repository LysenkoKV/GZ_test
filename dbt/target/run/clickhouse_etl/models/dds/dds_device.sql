
        
  
    
    
    
        
        insert into `dds`.`dim_device`
        ("click_id", "os", "os_name", "os_timezone", "device_type", "device_is_mobile", "user_custom_id", "user_domain_id", "__ods_load_time", "__dds_load_time", "__kafka_offset")







SELECT
    click_id,
    os,
    os_name,
    os_timezone,
    device_type,
    device_is_mobile,
    user_custom_id,
    user_domain_id,
    ods_load_time AS __ods_load_time,
    now() AS __dds_load_time,
    kafka_offset AS __kafka_offset
FROM `ods`.`device_data`
WHERE 1 = 1

  
  
    