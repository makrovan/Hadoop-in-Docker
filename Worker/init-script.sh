#!/bin/bash

apt update && apt install sudo -y

mkdir /usr/local/hadoop/logs
chown hdfs:hadoop /usr/local/hadoop/logs
chmod g+rwx /usr/local/hadoop/logs

# Start NodeManager - the first process
sudo -u yarn /usr/local/hadoop/bin/yarn nodemanager &

# Start DataNode - the second process
sudo -u hdfs /usr/local/hadoop/bin/hdfs datanode &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?