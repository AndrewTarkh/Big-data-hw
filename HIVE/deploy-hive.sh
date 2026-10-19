ssh -i ~/.ssh/team_internal team@team-02-01 "sudo apt-get update -y && sudo apt-get install -y postgresql"
ssh -i ~/.ssh/team_internal team@team-02-01 "sudo sed -i \"s/#listen_addresses = 'localhost'/listen_addresses = '*'/g\" /etc/postgresql/*/main/postgresql.conf"
ssh -i ~/.ssh/team_internal team@team-02-01 "echo \"host    metastore       hive            10.2.0.0/24             password\" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf"
ssh -i ~/.ssh/team_internal team@team-02-01 "sudo systemctl restart postgresql"

ssh -i ~/.ssh/team_internal team@team-02-01 "sudo -u postgres psql -c \"CREATE DATABASE metastore;\"" || true
ssh -i ~/.ssh/team_internal team@team-02-01 "sudo -u postgres psql -c \"CREATE USER hive WITH PASSWORD 'hiveMegaPass';\"" || true
ssh -i ~/.ssh/team_internal team@team-02-01 "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE \\\"metastore\\\" to hive;\""
ssh -i ~/.ssh/team_internal team@team-02-01 "sudo -u postgres psql -c \"ALTER DATABASE metastore OWNER TO hive;\""

sudo apt-get update -y && sudo apt-get install -y openjdk-17-jdk-headless postgresql-client
cd ~

wget https://dlcdn.apache.org/hadoop/common/hadoop-3.5.0/hadoop-3.5.0.tar.gz
tar -zxf hadoop-3.5.0.tar.gz
mv hadoop-3.5.0 hadoop
rm hadoop-3.5.0.tar.gz
wget https://archive.apache.org/dist/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz
tar -zxf apache-hive-4.0.1-bin.tar.gz
rm apache-hive-4.0.1-bin.tar.gz

cat << 'EOF' >> ~/.profile
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export HADOOP_HOME=/home/team/hadoop
export HIVE_HOME=/home/team/apache-hive-4.0.1-bin
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin
export JAVA_TOOL_OPTIONS="--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
--add-opens=java.base/java.io=ALL-UNNAMED \
--add-opens=java.base/java.util=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED \
--add-opens=java.base/java.util.regex=ALL-UNNAMED \
--add-opens=java.base/sun.nio.ch=ALL-UNNAMED"
EOF
source ~/.profile

cp configs/hive-site.xml $HIVE_HOME/conf/
wget -q https://jdbc.postgresql.org/download/postgresql-42.7.14.jar -O $HIVE_HOME/lib/postgresql-42.7.14.jar

scp -i ~/.ssh/team_internal team@team-02-nn:/home/andrey/hadoop/etc/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/
scp -i ~/.ssh/team_internal team@team-02-nn:/home/andrey/hadoop/etc/hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop/

ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -mkdir -p /tmp /user/hive/warehouse && sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -chmod -R 777 /tmp /user/hive/warehouse"
$HIVE_HOME/bin/schematool -dbType postgres -initSchema

nohup hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service metastore > /tmp/hms.log 2>&1 < /dev/null &
nohup hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service hiveserver2 > /tmp/hs2.log 2>&1 < /dev/null &