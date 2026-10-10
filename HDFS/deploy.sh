for node in team-02-nn team-02-00 team-02-01; do
    ssh -i ~/.ssh/team_internal team@$node "sudo apt-get update -y && sudo apt-get install -y openjdk-17-jdk-headless"
    
    if [ $node == team-02-nn ]; then
        ssh -i ~/.ssh/team_internal team@$node "sudo sed -i 's/127.0.1.1/10.2.0.11/g' /etc/hosts"
    fi

    ssh -i ~/.ssh/team_internal team@$node "id -u andrey &>/dev/null || sudo useradd -m -s /bin/bash andrey"
    ssh -i ~/.ssh/team_internal team@$node "sudo chown -R andrey:andrey /home/andrey && sudo chmod 755 /home/andrey"
done

KEY=$(ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey bash -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && ssh-keygen -q -t rsa -N \"\" -f ~/.ssh/id_rsa <<< y >/dev/null 2>&1; cat ~/.ssh/id_rsa.pub'")
for node in team-02-nn team-02-00 team-02-01; do
    ssh -i ~/.ssh/team_internal team@$node "sudo -u andrey bash -c 'mkdir -p ~/.ssh && echo \"$KEY\" >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys'"
    ssh -i ~/.ssh/team_internal team@$node "sudo -u andrey bash -c 'echo -e \"Host *\\n    StrictHostKeyChecking no\" > ~/.ssh/config && chmod 600 ~/.ssh/config'"
done

for node in team-02-nn team-02-00 team-02-01; do
    ssh -i ~/.ssh/team_internal team@$node "sudo -u andrey bash -c 'cd /home/andrey && rm -rf hadoop hadoop-3.5.0 hadoop.tar.gz'"
    ssh -i ~/.ssh/team_internal team@$node "sudo -u andrey wget -q https://dlcdn.apache.org/hadoop/common/hadoop-3.5.0/hadoop-3.5.0.tar.gz -O /home/andrey/hadoop.tar.gz"
    ssh -i ~/.ssh/team_internal team@$node "sudo -u andrey tar xzf /home/andrey/hadoop.tar.gz -C /home/andrey"
    ssh -i ~/.ssh/team_internal team@$node "sudo -u andrey mv /home/andrey/hadoop-3.5.0 /home/andrey/hadoop"
    ssh -i ~/.ssh/team_internal team@$node "sudo -u andrey rm /home/andrey/hadoop.tar.gz"
done

for node in team-02-nn team-02-00 team-02-01; do
    scp -i ~/.ssh/team_internal configs/* team@$node:/tmp/
    ssh -i ~/.ssh/team_internal team@$node "sudo -u andrey cp /tmp/*.xml /tmp/*.sh /tmp/workers /home/andrey/hadoop/etc/hadoop/"
    ssh -i ~/.ssh/team_internal team@$node "sudo rm -f /tmp/*.xml /tmp/workers /tmp/*.sh"
done

ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/hdfs namenode -format -force"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/sbin/start-dfs.sh"
