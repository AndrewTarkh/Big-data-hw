sudo apt-get update -y && sudo apt-get install -y python3-venv python3-pip
rm -rf /home/team/prefect-venv
python3 -m venv /home/team/prefect-venv
/home/team/prefect-venv/bin/pip install --no-cache-dir --upgrade pip
/home/team/prefect-venv/bin/pip install --no-cache-dir prefect pyspark==3.5.3