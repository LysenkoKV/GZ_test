select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with child as (
    select click_id as from_field
    from `dds`.`dim_browser`
    where click_id is not null
),

parent as (
    select click_id as to_field
    from `dds`.`fct_click`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null
settings join_use_nulls = 1



      
    ) dbt_internal_test