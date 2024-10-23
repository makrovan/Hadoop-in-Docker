#!/bin/bash
set -x
if [ `ls /usr/local/hadoop/data/nameNode/ | wc -l` -eq 0 ]; then
    printf "\n!!!Formatting hadoop file system...\n\n"
    /usr/local/hadoop/bin/hdfs namenode -format -force
fi
