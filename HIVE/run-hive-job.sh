export JAVA_TOOL_OPTIONS="--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
--add-opens=java.base/java.io=ALL-UNNAMED \
--add-opens=java.base/java.util=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED \
--add-opens=java.base/java.util.regex=ALL-UNNAMED \
--add-opens=java.base/sun.nio.ch=ALL-UNNAMED"

mkdir -p /home/team/data /home/team/hql
cat << 'EOF' > /home/team/data/sample.csv
1,Alex,2006
2,Maxim,2007
3,Andrew,2007
4,Kirill,2008
EOF

cat << 'SQL' > /home/team/hql/job.hql
CREATE DATABASE IF NOT EXISTS homework3;
USE homework3;
DROP TABLE IF EXISTS temp_users;
CREATE EXTERNAL TABLE temp_users (id INT, name STRING, year INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/input';
DROP TABLE IF EXISTS partitioned_users;
CREATE TABLE partitioned_users (id INT, name STRING)
PARTITIONED BY (year INT)
STORED AS PARQUET;
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;
INSERT OVERWRITE TABLE partitioned_users PARTITION (year)
SELECT id, name, year FROM temp_users;
SHOW PARTITIONS partitioned_users;
SELECT * FROM partitioned_users;
SQL

scp -i ~/.ssh/team_internal /home/team/data/sample.csv team@team-02-nn:/tmp/sample.csv
ssh -i ~/.ssh/team_internal team@team-02-nn "
    sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -mkdir -p /user/hive/input
    sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -put -f /tmp/sample.csv /user/hive/input/
    sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -chmod -R 777 /user/hive/input
    rm -f /tmp/sample.csv"
source ~/.profile
$HIVE_HOME/bin/beeline -u "jdbc:hive2://" -f /home/team/hql/job.hql