select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select click_id
from `dds`.`dim_device`
where click_id is null



      
    ) dbt_internal_test