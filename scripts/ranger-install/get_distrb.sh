#!/bin/bash
set -x

rm -rf ../../Data/Ranger_distrib/ranger
cd ../../Data/Ranger_distrib
rmdir ranger
# sudo chown -R user:user .m2/
# mkdir .m2
# chmod -R 777 .m2
# git clone --single-branch --branch ranger-2.4 https://github.com/apache/ranger
git clone https://github.com/apache/ranger
# wget https://downloads.apache.org/ranger/2.5.0/apache-ranger-2.5.0.tar.gz
# tar -xzf apache-ranger-2.5.0.tar.gz
# mv apache-ranger-2.5.0/ ranger/
# https://issues.apache.org/jira/browse/RANGER-4919

# install Java-11:
curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
tar zxvf openjdk-11.0.1_linux-x64_bin.tar.gz
