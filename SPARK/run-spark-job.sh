mkdir -p data scripts

cat << 'EOF' > data/orders.csv
1,Electronics,1200.50,2023
2,Books,45.00,2023
3,Electronics,850.00,2023
4,Clothing,120.00,2024
5,Clothing,85.50,2024
6,Books,30.00,2024
EOF

scp -i ~/.ssh/team_internal data/orders.csv team@team-02-nn:/tmp/orders.csv
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -rm -r -f /user/hive/input/orders"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -mkdir -p /user/hive/input/orders"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -put -f /tmp/orders.csv /user/hive/input/orders/orders.csv"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -chmod -R 777 /user/hive/input/orders"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo rm -f /tmp/orders.csv"

scp -i ~/.ssh/team_internal scripts/job.sql team@team-02-nn:/tmp/job.sql
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/spark/bin/spark-sql --master yarn --deploy-mode client -f /tmp/job.sql"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo rm -f /tmp/job.sql"
source ~/.profile
$HIVE_HOME/bin/beeline -u "jdbc:hive2://" -e "USE homework4; SHOW TABLES; SHOW PARTITIONS orders_report; SELECT * FROM orders_report;"