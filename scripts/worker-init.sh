#!/bin/bash

while [ `ls /etc/security/keytab | wc -l` -eq 0 ]
do
    sleep 5
    echo "waiting /etc/security/keytab..."
done

# Start DataNode - the second process
su -c "/usr/local/hadoop/bin/hdfs datanode &" hdfs

# Start NodeManager - the first process
su -c "/usr/local/hadoop/bin/yarn nodemanager &" yarn

# Wait for any process to exit
sleep 10
pid="$(pidof java)"
echo "loop started!"
myloop=true; while $myloop; do for i in $pid; do if (ps $i >> /dev/null); then sleep 5; else myloop=false; kill $(pidof -s java); break; fi; sleep 5; done; done
echo "loop finished!"