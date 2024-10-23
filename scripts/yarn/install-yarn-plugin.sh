#!/bin/bash
set -x

# https://cwiki.apache.org/confluence/display/RANGER/Ranger+installation+in+Kerberized++Environment#RangerinstallationinKerberizedEnvironment-Installing/EnablingRangerYARNplugin
echo "Installing ranger-yarn...."
cd /usr/local
tar zxf ranger-2.5.1-SNAPSHOT-yarn-plugin.tar.gz
ln -s ranger-2.5.1-SNAPSHOT-yarn-plugin ranger-yarn
cd ranger-yarn
cp -f /tmp/yarn/install.properties .
./enable-yarn-plugin.sh
