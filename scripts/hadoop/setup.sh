#!/bin/bash

apt update && apt install -y openjdk-8-jdk wget krb5-user 
    #Default Kerberos version 5 realm: DOCKER.NET
    #Kerberos servers for your realm: kdc-server.docker.net
    #Administrative server for your Kerberos realm: kdc-server.docker.net
cd /tmp
wget https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.4.0-aarch64.tar.gz
tar xzf hadoop-3.4.0-aarch64.tar.gz -C /usr/local
rm hadoop-3.4.0-aarch64.tar.gz
mv /usr/local/hadoop-3.4.0 /usr/local/hadoop

addgroup hadoop
adduser --ingroup hadoop --comment "" hdfs 
    #password: hadoop
adduser --ingroup hadoop --comment "" yarn 
    #password: hadoop
adduser --ingroup hadoop --comment "" mapred 
    #password: hadoop

mkdir -p -m 700 /usr/local/hadoop/data/nameNode
mkdir -p -m 700 /usr/local/hadoop/data/dataNode
mkdir -p -m 775 /usr/local/hadoop/logs
mkdir -p -m 755 /tmp/hadoop-yarn/nm-local-dir
mkdir -p -m 755 /usr/local/hadoop/logs/userlogs
chown hdfs:hadoop -R /usr/local/hadoop/data/nameNode
chown hdfs:hadoop -R /usr/local/hadoop/data/dataNode
chown hdfs:hadoop -R /usr/local/hadoop/logs
chown yarn:hadoop -R /tmp/hadoop-yarn/nm-local-dir
chown yarn:hadoop -R /usr/local/hadoop/logs/userlogs