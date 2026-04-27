
        
  
    
    
    
        
        insert into `ods`.`device_data`
        ("click_id", "os", "os_name", "os_timezone", "device_type", "device_is_mobile", "user_custom_id", "user_domain_id", "kafka_offset", "kafka_partition", "kafka_timestamp", "raw_load_time", "ods_load_time")







SELECT
    CAST(JSONExtractString(message, 'click_id') AS UUID) AS click_id,
    CAST(JSONExtractString(message, 'os') AS String) AS os,
    CAST(JSONExtractString(message, 'os_name') AS String) AS os_name,
    CAST(JSONExtractString(message, 'os_timezone') AS String) AS os_timezone,
    CAST(JSONExtractString(message, 'device_type') AS String) AS device_type,
    CAST(JSONExtractString(message, 'device_is_mobile') AS Bool) AS device_is_mobile,
    CAST(JSONExtractString(message, 'user_custom_id') AS String) AS user_custom_id,
    CAST(JSONExtractString(message, 'user_domain_id') AS UUID) AS user_domain_id,
    offset AS kafka_offset,
    partition AS kafka_partition,
    timestamp_kafka AS kafka_timestamp,
    load_time AS raw_load_time,
    now() AS ods_load_time
FROM  `raw`.`device_data`
WHERE
    isValidJSON(message) = 1
    AND JSONExtractString(message, 'click_id') != ''



-- Проблемы:
-- 1. Могут быть старые данные с большим временем (часовые пояса)
-- 2. В Kafka время может идти не монотонно
-- 3. При перезагрузке старых данных они не попадут
-- Преимущества:
-- 1. offset строго монотонно возрастает в рамках партиции
-- 2. Не зависит от времени
-- 3. Гарантирует, что каждое сообщение обработается ровно один раз
  
  
    