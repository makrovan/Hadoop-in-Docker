#!/bin/bash
set -x
kinit -k -t /etc/security/keytabs/my.keytab hdfs@DOCKER.NET
printf "\n!!!Testing hadoop file system...\n"

echo 'waiting for start of the namenode...'
/usr/local/hadoop/bin/hdfs dfs -ls /
while [ ! $? -eq 0 ]; do
    printf "\n!!!Waitint for namenode...\n"
    sleep 3
    /usr/local/hadoop/bin/hdfs dfs -ls /
done

/usr/local/hadoop/bin/hdfs dfs -test -d /tmp
if [ ! $? -eq 0 ]; then
    printf "\n!!!Initializing hadoop file system...\n"
    /usr/local/hadoop/bin/hdfs dfs -mkdir /tmp
    /usr/local/hadoop/bin/hdfs dfs -mkdir /user
    # yarn.nodemanager.remote-app-log-dir
    /usr/local/hadoop/bin/hdfs dfs -mkdir /tmp/logs
    # mapreduce.jobhistory.intermediate-done-dir
    /usr/local/hadoop/bin/hdfs dfs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate
    # mapreduce.jobhistory.done-dir
    /usr/local/hadoop/bin/hdfs dfs -mkdir -p /tmp/hadoop-yarn/staging/history/done
    /usr/local/hadoop/bin/hdfs dfs -mkdir -p /mr-history/done
    /usr/local/hadoop/bin/hdfs dfs -mkdir -p /mr-history/tmp
    /usr/local/hadoop/bin/hdfs dfs -mkdir -p /mr-history
    /usr/local/hadoop/bin/hdfs dfs -chmod 750 /tmp/hadoop-yarn/staging/history/done_intermediate
    /usr/local/hadoop/bin/hdfs dfs -chmod 777 /tmp/hadoop-yarn/staging/history/done_intermediate
    /usr/local/hadoop/bin/hdfs dfs -chmod 777 /tmp/logs
    /usr/local/hadoop/bin/hdfs dfs -chmod 777 /mr-history/done
    /usr/local/hadoop/bin/hdfs dfs -chmod 777 /mr-history/tmp
    /usr/local/hadoop/bin/hdfs dfs -chmod 777 /mr-history
    /usr/local/hadoop/bin/hdfs dfs -chmod 755 /user
    /usr/local/hadoop/bin/hdfs dfs -chmod 777 /tmp
    /usr/local/hadoop/bin/hdfs dfs -chmod 755 /
    /usr/local/hadoop/bin/hdfs dfs -chown mapred:hadoop /tmp/hadoop-yarn/staging/history/done
    /usr/local/hadoop/bin/hdfs dfs -chown mapred:hadoop /tmp/hadoop-yarn/staging/history/done_intermediate
    /usr/local/hadoop/bin/hdfs dfs -chown yarn:hadoop /tmp/logs
    /usr/local/hadoop/bin/hdfs dfs -chown mapred:hadoop /mr-history/done
    /usr/local/hadoop/bin/hdfs dfs -chown mapred:hadoop /mr-history/tmp
    /usr/local/hadoop/bin/hdfs dfs -chown mapred:hadoop /mr-history
    /usr/local/hadoop/bin/hdfs dfs -chown hdfs:hadoop /user
    /usr/local/hadoop/bin/hdfs dfs -chown hdfs:hadoop /tmp
    /usr/local/hadoop/bin/hdfs dfs -chown hdfs:hadoop /
fi
kdestroy
