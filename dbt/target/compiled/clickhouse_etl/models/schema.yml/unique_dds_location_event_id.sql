
    
    

select
    event_id as unique_field,
    count(*) as n_records

from `ods_dds`.`dim_location`
where event_id is not null
group by event_id
having count(*) > 1


