-- Слои
CREATE DATABASE IF NOT EXISTS raw;

CREATE DATABASE IF NOT EXISTS ods;

CREATE DATABASE IF NOT EXISTS dds;

CREATE DATABASE IF NOT EXISTS log;

-- Таблицы для чтения из Kafka
CREATE TABLE IF NOT EXISTS raw.browser_stream (
    message String
) ENGINE = Kafka
SETTINGS 
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'browser_events',
    kafka_group_name = 'clickhouse_consumer',
    kafka_format = 'JSONAsString';

CREATE TABLE IF NOT EXISTS raw.device_stream (
    message String
) ENGINE = Kafka
SETTINGS 
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'device_events',
    kafka_group_name = 'clickhouse_consumer',
    kafka_format = 'JSONAsString';

CREATE TABLE IF NOT EXISTS raw.geo_stream (
    message String
) ENGINE = Kafka
SETTINGS 
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'geo_events',
    kafka_group_name = 'clickhouse_consumer',
    kafka_format = 'JSONAsString';

CREATE TABLE IF NOT EXISTS raw.location_stream (
    message String
) ENGINE = Kafka
SETTINGS 
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'location_events',
    kafka_group_name = 'clickhouse_consumer',
    kafka_format = 'JSONAsString';

CREATE TABLE IF NOT EXISTS log.error_stream (
    message String
) ENGINE = Kafka
SETTINGS 
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'error_log',
    kafka_group_name = 'clickhouse_consumer',
    kafka_format = 'JSONAsString';

CREATE TABLE IF NOT EXISTS log.ETL_LOG (
    log_id UUID,
    table_name String,
    operation String,
    operation_time DateTime64(3),
    status String
) ENGINE = MergeTree()
ORDER BY (table_name, operation_time);

-- Таблицы для хранения данных
CREATE TABLE IF NOT EXISTS raw.browser_data (
    message String,
    topic LowCardinality(String),
    partition UInt64,
    offset UInt64,
    timestamp_kafka DateTime64(3),
    kafka_key String,
    headers_keys Array(String),
    headers_values Array(String),
    load_time DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY (partition, offset);

CREATE TABLE IF NOT EXISTS raw.device_data (
    message String,
    topic LowCardinality(String),
    partition UInt64,
    offset UInt64,
    timestamp_kafka DateTime64(3),
    kafka_key String,
    headers_keys Array(String),
    headers_values Array(String),
    load_time DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY (partition, offset);

CREATE TABLE IF NOT EXISTS raw.geo_data (
    message String,
    topic LowCardinality(String),
    partition UInt64,
    offset UInt64,
    timestamp_kafka DateTime64(3),
    kafka_key String,
    headers_keys Array(String),
    headers_values Array(String),
    load_time DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY (partition, offset);

CREATE TABLE IF NOT EXISTS raw.location_data (
    message String,
    topic LowCardinality(String),
    partition UInt64,
    offset UInt64,
    timestamp_kafka DateTime64(3),
    kafka_key String,
    headers_keys Array(String),
    headers_values Array(String),
    load_time DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY (partition, offset);

CREATE TABLE IF NOT EXISTS log.error_data (
    message String,
    topic LowCardinality(String),
    partition UInt64,
    offset UInt64,
    timestamp_kafka DateTime64(3),
    kafka_key String,
    headers_keys Array(String),
    headers_values Array(String),
    load_time DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY (partition, offset);

--Представления для загрузки данных
CREATE MATERIALIZED VIEW IF NOT EXISTS raw.browser_loader TO raw.browser_data AS
SELECT
    message as message,
    _topic AS topic,
    _partition AS partition,
    _offset AS offset,
    _timestamp_ms AS timestamp_kafka,
    _key AS kafka_key,
    _headers.name AS headers_keys,
    _headers.value AS headers_values,
    now() AS load_time 
FROM raw.browser_stream;

CREATE MATERIALIZED VIEW IF NOT EXISTS raw.device_loader TO raw.device_data AS
SELECT
    message as message,
    _topic AS topic,
    _partition AS partition,
    _offset AS offset,
    _timestamp_ms AS timestamp_kafka,
    _key AS kafka_key,
    _headers.name AS headers_keys,
    _headers.value AS headers_values,
    now() AS load_time 
FROM raw.device_stream;

CREATE MATERIALIZED VIEW IF NOT EXISTS raw.geo_loader TO raw.geo_data AS
SELECT
    message as message,
    _topic AS topic,
    _partition AS partition,
    _offset AS offset,
    _timestamp_ms AS timestamp_kafka,
    _key AS kafka_key,
    _headers.name AS headers_keys,
    _headers.value AS headers_values,
    now() AS load_time 
FROM raw.geo_stream;

CREATE MATERIALIZED VIEW IF NOT EXISTS raw.location_loader TO raw.location_data AS
SELECT
    message as message,
    _topic AS topic,
    _partition AS partition,
    _offset AS offset,
    _timestamp_ms AS timestamp_kafka,
    _key AS kafka_key,
    _headers.name AS headers_keys,
    _headers.value AS headers_values,
    now() AS load_time 
FROM raw.location_stream;

CREATE MATERIALIZED VIEW IF NOT EXISTS log.error_loader TO log.error_data AS
SELECT
    message as message,
    _topic AS topic,
    _partition AS partition,
    _offset AS offset,
    _timestamp_ms AS timestamp_kafka,
    _key AS kafka_key,
    _headers.name AS headers_keys,
    _headers.value AS headers_values,
    now() AS load_time 
FROM log.error_stream;

