#!/bin/sh

until [ -e /etc/security/keytab/my.keytab ];do
    sleep 10
    echo "still waiting"
done
kinit -k -t /etc/security/keytab/my.keytab hdfs@DOCKER.NET 
firefox about:config \
    https://hadoop-master.docker.net:9871 \
    https://hadoop-rmanager.docker.net:8090 \
    https://hadoop-proxy.docker.net:9090 \
    https://hadoop-history.docker.net:19890