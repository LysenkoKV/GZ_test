from datetime import datetime
from airflow import DAG
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.bash import BashOperator


with DAG(
    dag_id='tests_run',
    schedule_interval=None,
    start_date=datetime(2026, 4, 1),
    catchup=False,
    description='Запуск DBT тестов',
    tags=['DBT tests']
) as dag:

    run_dbt = BashOperator(
        task_id='run_dbt_tests',
        bash_command='dbt test',
        cwd='/opt/airflow/dbt'
    )