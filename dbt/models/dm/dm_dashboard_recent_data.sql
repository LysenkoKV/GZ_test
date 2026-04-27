{{
    config(
        materialized='view',
        schema='dm',
        alias='dashboard_recent_data'
    )
}}

SELECT
    event_timestamp,
    geo_country,
    browser_name,
    device_is_mobile,
    utm_source,
    utm_medium,
    utm_campaign,
    click_id,
    event_id,
    __dds_load_time
FROM {{ref('dm_dashboard')}} FINAL
