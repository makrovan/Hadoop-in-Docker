#!/bin/bash

apt-get update
apt-get install openjdk-8-jdk wget krb5-user -y 
    #Default Kerberos version 5 realm: DOCKER.NET
    #Kerberos servers for your realm: kdc-server.docker.net
    #Administrative server for your Kerberos realm: kdc-server.docker.net
cd /usr/local
wget https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.4.0-aarch64.tar.gz
tar xzf hadoop-3.4.0-aarch64.tar.gz
mv hadoop-3.4.0 hadoop
rm hadoop-3.4.0-aarch64.tar.gz
addgroup hadoop
adduser --ingroup hadoop hdfs 
    #password: hadoop
adduser --ingroup hadoop yarn 
    #password: hadoop
adduser --ingroup hadoop mapred 
    #password: hadoop
su hdfs
cd ~
keytool -genkey -alias jetty -keyalg RSA 
    #Enter keystore password: hadoop
    #What is your first and last name? hadoop-master.docker.net
    #Enter key password for <jetty>: hadoop
exit
mkdir -p -m 700 /usr/local/hadoop/data/nameNode
mkdir -p -m 700 /usr/local/hadoop/data/dataNade
mkdir -p -m 775 /usr/local/hadoop/logs
mkdir -p -m 755 /tmp/hadoop-yarn/nm-local-dir
mkdir -p -m 755 /usr/local/hadoop/logs/userlogs
chown hdfs:hadoop -R /usr/local/hadoop/data/nameNode
chown hdfs:hadoop -R /usr/local/hadoop/data/dataNade
chown hdfs:hadoop -R /usr/local/hadoop/logs
chown yarn:hadoop -R /tmp/hadoop-yarn/nm-local-dir
chown yarn:hadoop -R /usr/local/hadoop/logs/userlogs