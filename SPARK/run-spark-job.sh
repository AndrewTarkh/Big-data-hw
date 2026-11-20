mkdir -p data scripts

cat << 'EOF' > data/orders.csv
1,Electronics,1200.50,2023
2,Books,45.00,2023
3,Electronics,850.00,2023
4,Clothing,120.00,2024
5,Clothing,85.50,2024
6,Books,30.00,2024
EOF

HADOOP_USER_NAME=andrey /home/team/hadoop/bin/hdfs dfs -rm -r -f /user/hive/input/orders
HADOOP_USER_NAME=andrey /home/team/hadoop/bin/hdfs dfs -mkdir -p /user/hive/input/orders
HADOOP_USER_NAME=andrey /home/team/hadoop/bin/hdfs dfs -put -f data/orders.csv /user/hive/input/orders/orders.csv
HADOOP_USER_NAME=andrey /home/team/hadoop/bin/hdfs dfs -chmod -R 777 /user/hive/input/orders

/home/team/spark/bin/spark-sql --master yarn --deploy-mode client -f scripts/job.sql

source ~/.profile
$HIVE_HOME/bin/beeline -u "jdbc:hive2://" -e "USE homework4; SHOW TABLES; SHOW PARTITIONS orders_report; SELECT * FROM orders_report;"