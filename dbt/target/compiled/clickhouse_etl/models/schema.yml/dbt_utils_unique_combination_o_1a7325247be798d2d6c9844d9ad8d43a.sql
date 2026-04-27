





with validation_errors as (

    select
        user_custom_id, user_domain_id
    from `ods_dds`.`dim_device`
    group by user_custom_id, user_domain_id
    having count(*) > 1

)

select *
from validation_errors


