
    
    

with child as (
    select event_id as from_field
    from `dds`.`dim_browser`
    where event_id is not null
),

parent as (
    select event_id as to_field
    from `dds`.`fct_click`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null
settings join_use_nulls = 1


