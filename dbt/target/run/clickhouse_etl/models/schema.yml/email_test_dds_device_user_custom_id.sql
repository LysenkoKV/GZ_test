select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

    SELECT user_custom_id
    FROM `dds`.`dim_device`
    WHERE NOT match(user_custom_id, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')


      
    ) dbt_internal_test