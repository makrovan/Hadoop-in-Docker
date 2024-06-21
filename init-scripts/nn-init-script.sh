#!/bin/bash

if [ `ls /usr/local/hadoop/data/nameNode/ | wc -l` -eq 0 ]; then
    /usr/local/hadoop/bin/hdfs namenode -format -force
    echo "formated!!!"

    if [ $? -eq 0 ]
    then
        /tmp/init-filesystem.sh &
    fi
fi

/usr/local/hadoop/bin/hdfs namenode