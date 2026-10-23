ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey rm -rf /home/andrey/spark /home/andrey/spark-3.5.3-bin-hadoop3 /home/andrey/spark-3.5.3-bin-hadoop3.tgz"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey wget -q https://archive.apache.org/dist/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz -O /home/andrey/spark-3.5.3-bin-hadoop3.tgz"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey tar -xzf /home/andrey/spark-3.5.3-bin-hadoop3.tgz -C /home/andrey"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey mv /home/andrey/spark-3.5.3-bin-hadoop3 /home/andrey/spark"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey rm -f /home/andrey/spark-3.5.3-bin-hadoop3.tgz"

scp -i ~/.ssh/team_internal configs/spark-defaults.conf configs/hive-site.xml team@team-02-nn:/tmp/
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey cp /tmp/spark-defaults.conf /home/andrey/spark/conf/"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey cp /tmp/hive-site.xml /home/andrey/spark/conf/"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey cp /home/andrey/hadoop/etc/hadoop/core-site.xml /home/andrey/spark/conf/"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey cp /home/andrey/hadoop/etc/hadoop/yarn-site.xml /home/andrey/spark/conf/"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo rm -f /tmp/spark-defaults.conf /tmp/hive-site.xml"

ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey wget -q https://jdbc.postgresql.org/download/postgresql-42.7.14.jar -O /home/andrey/spark/jars/postgresql-42.7.14.jar"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey bash -c 'cd /home/andrey/spark/jars && jar cv0f /tmp/spark-libs.zip *.jar'"

ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -mkdir -p /apps/spark"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -put -f /tmp/spark-libs.zip /apps/spark/spark-libs.zip"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/hdfs dfs -chmod -R 755 /apps/spark"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo rm -f /tmp/spark-libs.zip"

ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/spark/bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode client /home/andrey/spark/examples/jars/spark-examples*.jar 10"