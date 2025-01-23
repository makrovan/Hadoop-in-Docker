#!/bin/bash
set -x

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
