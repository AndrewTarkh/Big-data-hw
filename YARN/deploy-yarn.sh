for node in team-02-nn team-02-00 team-02-01; do
    scp -i ~/.ssh/team_internal configs/yarn-site.xml configs/mapred-site.xml team@$node:/tmp/
    ssh -i ~/.ssh/team_internal team@$node "sudo -u andrey cp /tmp/yarn-site.xml /tmp/mapred-site.xml /home/andrey/hadoop/etc/hadoop/"
    ssh -i ~/.ssh/team_internal team@$node "sudo rm -f /tmp/yarn-site.xml /tmp/mapred-site.xml"
done

ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/sbin/start-yarn.sh"
ssh -i ~/.ssh/team_internal team@team-02-nn "sudo -u andrey /home/andrey/hadoop/bin/mapred --daemon start historyserver"