#!/bin/bash

# set -x
cd /ranger

# если plugin-ы уже скомпилированы:
if [ `ls /ranger/target | wc -l` -gt 20 ]; then exit; fi

usermod -u $(stat -c "%u" pom.xml) builder 
gosu builder bash -c 'ln -sf /.m2 $HOME'
exec gosu builder mvn -Pall -DskipTests=true clean compile package install