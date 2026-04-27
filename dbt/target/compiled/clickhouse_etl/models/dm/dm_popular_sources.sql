-- Ежедневная агрегация для трендов


SELECT 
    loc.referer_medium AS "Канал",
    loc.utm_medium AS "Тип трафика",
    loc.utm_source AS "Источник",
    COUNT(DISTINCT dv.user_custom_id) AS "Кол-во уникальных пользователей",
    COUNT(*) AS "Всего событий",
    COUNT(*) / COUNT(DISTINCT dv.user_custom_id) AS "Среднее количество переходов на пользователя"
FROM `ods_dds`.`fct_click` fct
LEFT JOIN `ods_dds`.`dim_device` dv ON fct.click_id = dv.click_id
LEFT JOIN `ods_dds`.`dim_location` loc ON fct.event_id = loc.event_id
GROUP BY 
    loc.referer_medium,
    loc.utm_medium,
    loc.utm_source