sudo sed -i 's/127.0.1.1/10.2.0.10/g' /etc/hosts
rm -rf /home/team/spark /home/team/spark-3.5.3-bin-hadoop3 /home/team/spark-3.5.3-bin-hadoop3.tgz
wget -q https://archive.apache.org/dist/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz -O /home/team/spark-3.5.3-bin-hadoop3.tgz
tar -xzf /home/team/spark-3.5.3-bin-hadoop3.tgz -C /home/team
mv /home/team/spark-3.5.3-bin-hadoop3 /home/team/spark
rm -f /home/team/spark-3.5.3-bin-hadoop3.tgz

cp configs/spark-defaults.conf configs/spark-env.sh configs/hive-site.xml /home/team/spark/conf/
chmod +x /home/team/spark/conf/spark-env.sh

scp -i ~/.ssh/team_internal team@team-02-nn:/home/andrey/hadoop/etc/hadoop/hdfs-site.xml /home/team/hadoop/etc/hadoop/
cp /home/team/hadoop/etc/hadoop/core-site.xml /home/team/hadoop/etc/hadoop/hdfs-site.xml /home/team/hadoop/etc/hadoop/yarn-site.xml /home/team/spark/conf/

wget -q https://jdbc.postgresql.org/download/postgresql-42.7.14.jar -O /home/team/spark/jars/postgresql-42.7.14.jar
(cd /home/team/spark/jars && jar cv0f /tmp/spark-libs.zip *.jar)

HADOOP_USER_NAME=andrey /home/team/hadoop/bin/hdfs dfs -mkdir -p /apps/spark /user/team
HADOOP_USER_NAME=andrey /home/team/hadoop/bin/hdfs dfs -put -f /tmp/spark-libs.zip /apps/spark/spark-libs.zip
HADOOP_USER_NAME=andrey /home/team/hadoop/bin/hdfs dfs -chmod -R 755 /apps/spark
HADOOP_USER_NAME=andrey /home/team/hadoop/bin/hdfs dfs -chmod -R 777 /user/team
rm -f /tmp/spark-libs.zip

/home/team/spark/bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode client /home/team/spark/examples/jars/spark-examples*.jar 10