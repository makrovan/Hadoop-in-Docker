#!/bin/bash

apt update && apt install sudo -y

while [ `ls /etc/security/keytab | wc -l` -eq 0 ]
do
    sleep 5
    echo "waiting /etc/security/keytab..."
done

# Start NodeManager - the first process
sudo -u yarn /usr/local/hadoop/bin/yarn nodemanager &

# Start DataNode - the second process
sudo -u hdfs /usr/local/hadoop/bin/hdfs datanode &

# Wait for any process to exit
# https://www.gnu.org/software/bash/manual/html_node/Job-Control-Builtins.html#index-wait
wait -n

# Exit with status of process that exited first
exit $?