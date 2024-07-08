#!/bin/sh -x

kinit -k -t /etc/security/keytab/my.keytab hdfs@DOCKER.NET 
while [ $? -ne 0 ]
do
    sleep 5
    echo "waiting kinit..."
    kinit -k -t /etc/security/keytab/my.keytab hdfs@DOCKER.NET 
done

firefox about:config \
    https://hadoop-master.docker.net:9871 \
    https://hadoop-rmanager.docker.net:8090 \
    https://hadoop-history.docker.net:19890 \
    http://hadoop-solr.docker.net:6083 \
    http://hadoop-ranger.docker.net:6080

# sleep infinity&
# wait $!