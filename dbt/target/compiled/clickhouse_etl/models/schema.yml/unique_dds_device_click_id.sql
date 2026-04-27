
    
    

select
    click_id as unique_field,
    count(*) as n_records

from `ods_dds`.`dim_device`
where click_id is not null
group by click_id
having count(*) > 1


