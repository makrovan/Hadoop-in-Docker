#!/bin/bash
set -x

# https://cwiki.apache.org/confluence/display/RANGER/Ranger+installation+in+Kerberized++Environment#RangerinstallationinKerberizedEnvironment-Installing/EnablingRangerHDFSplugin
echo "Installing ranger-hdfs...."
cd /usr/local
tar zxf ranger-2.5.1-SNAPSHOT-hdfs-plugin.tar.gz
ln -s ranger-2.5.1-SNAPSHOT-hdfs-plugin ranger-hdfs
cd ranger-hdfs
cp -f /tmp/hdfs/install.properties .
./enable-hdfs-plugin.sh
