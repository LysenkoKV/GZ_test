from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from confluent_kafka import Producer
import json
import os
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
log = logging.getLogger(__name__)

def get_data():
    try:
        conf = {'bootstrap.servers': 'kafka:9092'}
        producer = Producer(conf)
        data_path = r'/opt/airflow/data/'

        for filename in os.listdir(data_path):
            
            if filename.endswith('.jsonl'):
                filepath = os.path.join(data_path, filename)
                topic_name = os.path.splitext(filename)[0]
                
                log.info(f"Обрабатывается файл: {filename}")
                
                with open(filepath, 'r', encoding='utf-8') as f:
                    for line_num, line in enumerate(f, 1):
                        if line.strip():
                            try:
                                data = json.loads(line)
                                producer.produce(
                                    topic = topic_name,
                                    key = 'TestKey',
                                    value = json.dumps(data).encode('utf-8'),
                                    headers = [("source", "airflow")]
                                )
                                if line_num % 100 == 0:
                                    log.info(f"Отправлено {line_num} сообщений")
                            except Exception as e:
                                log.error(f"Ошибка JSON в строке: {line_num}: {e}")
                                try:
                                    error_message = json.dumps({"message": str(line).strip()})
                                    producer.produce(
                                        topic = 'error_log',
                                        key = 'TestKey',
                                        value = error_message,
                                        headers = [("source", "airflow")]
                                    )
                                    producer.flush()
                                except Exception as e:
                                    log.error(f"Не удалось записать в лог CH строку под номером: {line_num} из-за ошибки: {e}")
                
                log.info(f"Обработка файла {filename} завершена")
        
        producer.flush()
        log.info(f"Обработка файлов успешно завершена")
    except Exception as e:
        log.error(f"Выполнение цепочки DAG прервано из-за кричической ошибки при загрузке данных в Kafka: {e}")
        raise

with DAG(
    'kafka_producer',
    start_date=datetime(2026, 4, 1),
    schedule_interval='30 18 * * *',
    catchup=False,
    description='Отправка JSON в Kafka',
    tags=['kafka']
) as dag:
    
    send_task = PythonOperator(
        task_id='get_data',
        python_callable=get_data
    )


    update_layers = TriggerDagRunOperator(
        task_id='execute_update_layers',
        trigger_dag_id='layers_update',
        wait_for_completion=False
    )

    send_task >> update_layers