

  create view `ods_dm`.`geo_stat__dbt_tmp` 
  
    
    
  as (
    -- Ежедневная агрегация для трендов


SELECT 
    geo.geo_country AS "Страна",
    geo.geo_region_name AS "Город",
    count(distinct dv.user_custom_id) AS "Кол-во уникальных пользователей"
FROM `ods_dds`.`fct_click` fct
LEFT JOIN `ods_dds`.`dim_geo` geo ON fct.click_id = geo.click_id
LEFT JOIN `ods_dds`.`dim_device` dv ON fct.click_id = dv.click_id
GROUP BY 
    geo.geo_country,
    geo.geo_region_name
  )