#!/bin/bash

if ! [ -a /usr/local/hadoop/data/nameNode/* ]; then
    /usr/local/hadoop/bin/hdfs namenode -format -force
    echo "formated!!!"
fi

/usr/local/hadoop/bin/hdfs namenode