
    
    

with all_values as (

    select
        device_is_mobile as value_field,
        count(*) as n_records

    from `dds`.`dim_device`
    group by device_is_mobile

)

select *
from all_values
where value_field not in (
    'True','False'
)


