
    
    

with all_values as (

    select
        device_type as value_field,
        count(*) as n_records

    from `dds`.`dim_device`
    group by device_type

)

select *
from all_values
where value_field not in (
    'Mobile','Computer'
)


