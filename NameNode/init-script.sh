#!/bin/bash

if ! [ -a /usr/local/hadoop/data/nameNode/* ]; then
    /usr/local/hadoop/bin/hdfs namenode -format -force
fi

/usr/local/hadoop/bin/hdfs namenode

# while true
# do
    # sleep 100;
# done