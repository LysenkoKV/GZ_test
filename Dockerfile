FROM apache/airflow:2.10.5
USER airflow
RUN pip install --index-url https://mirrors.aliyun.com/pypi/simple/ \
    clickhouse-connect==0.7.0 \
    kafka-python==2.0.2 \
    apache-airflow-providers-apache-kafka==1.3.0 \
    dbt-core==1.7.0 \
    dbt-clickhouse==1.7.0