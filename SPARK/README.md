## Автоматизированное развертывание HIVE
Репозиторий содержит скрипты и конфигурационные файлы для автоматизированного развертывания SPARK поверх существующего кластера Hadoop HDFS, YARN, HIVE, а также автоматизации чтения, агрегации, динамического партиционирования и сохранения данных в формате Parquet с последующей валидацией через клиент Hive. 

## Архитектура кластера

Развертывание производится на следующих виртуальных машинах (ОС Ubuntu):
* team-02-nn - Spark Client / Driver
* team-02-00 - Spark Executor
* team-02-01 - Spark Executor

## Структура репозитория

```
.
├── deploy-spark.sh       # bash-скрипт автоматизированного развертывания
├── run-spark-job.sh      # bash-скрипт загрузки данных на HDFS, запуска Spark-пайплайна и проверки через Beeline
├── job.sql               # SQL-пайплайн
└── configs/              # конфигурационные файлы
    └── spark-defaults.conf
```
## Инструкция по запуску
С локальной машины отправить скрипт и конфигурации на edge-ноду:
```
scp -i ~/.ssh/<SSH_KEY> -r deploy-spark.sh run-spark-job.sh configs scripts team@<IP_EDGE_NODE>:~
ssh -i ~/.ssh/<SHH> team@111.88.128.191 
```
Затем выполнить:
```
chmod +x deploy-spark.sh run-spark-job.sh
./deploy-spark.sh
./run-spark-job.sh
```

## Инструкция по остановке
Остановка HIVE: pkill -f RunJar

Остановка HistoryServer: ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/mapred --daemon stop historyserver"

Остановка YARN: ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/sbin/stop-yarn.sh"

Остановка HDFS: ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/sbin/stop-dfs.sh"

Остановка PostgreSQL: ssh -i ~/.ssh/team_internal team@team-02-01 "sudo systemctl stop postgresql"