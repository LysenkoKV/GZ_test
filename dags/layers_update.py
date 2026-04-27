from datetime import datetime
from airflow import DAG
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.bash import BashOperator

with DAG(
    dag_id='layers_update',
    schedule_interval=None,
    start_date=datetime(2026, 4, 1),
    catchup=False,
    description='Запуск DBT моделкй',
    tags=['DBT update']
) as dag:

    run_dbt = BashOperator(
        task_id='run_dbt',
        bash_command='dbt run',
        cwd='/opt/airflow/dbt'
    )
    
    run_tests = TriggerDagRunOperator(
        task_id='execute_run_tests',
        trigger_dag_id='tests_run',
        wait_for_completion=False
    )

    run_dbt >> run_tests