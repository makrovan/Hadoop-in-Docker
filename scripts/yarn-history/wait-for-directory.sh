#!/bin/bash
set -x

kinit -k -t /etc/security/keytabs/rm.service.keytab rm/hadoop-proxy.hadoopnet@HADOOPNET
while [ $? -ne 0 ]
do
    sleep 5
    echo "kinit error..."
    kinit -k -t /etc/security/keytabs/rm.service.keytab rm/hadoop-proxy.hadoopnet@HADOOPNET
done

printf "\n!!!Testing directory to yarn-history...\n\n"
/usr/local/hadoop/bin/hdfs dfs -test -d /mr-history
while [ ! $? -eq 0 ]; do
    printf "\n!!!Waitint for directory to yarn-history...\n\n"
    sleep 5
    /usr/local/hadoop/bin/hdfs dfs -test -d /mr-history
done

kdestroy