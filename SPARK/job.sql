CREATE DATABASE IF NOT EXISTS homework4;
USE homework4;

DROP TABLE IF EXISTS raw_orders;
CREATE EXTERNAL TABLE raw_orders (
    order_id INT,
    category STRING,
    amount DOUBLE,
    order_year INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/input/orders';

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

DROP TABLE IF EXISTS orders_report;
CREATE TABLE orders_report (
    category STRING,
    total_orders BIGINT,
    total_sum DOUBLE,
    avg_amount DOUBLE
)
PARTITIONED BY (order_year INT)
STORED AS PARQUET;

INSERT OVERWRITE TABLE orders_report PARTITION (order_year)
SELECT 
    category,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_sum,
    ROUND(AVG(amount), 2) AS avg_amount,
    order_year
FROM raw_orders
GROUP BY category, order_year;