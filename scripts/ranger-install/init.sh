#!/bin/bash
set -x

java -version

# set -x
cd /ranger

# если plugin-ы уже скомпилированы:
if [ `ls /ranger/target | wc -l` -gt 20 ]; then exit; fi

usermod -u $(stat -c "%u" pom.xml) builder 
gosu builder bash -c 'ln -sf /.m2 $HOME'
# exec gosu builder mvn -Pall -DskipTests=true clean compile package install
exec gosu builder mvn clean compile package install -Dmaven.test.skip=true -Drat.skip=true -Dpmd.skip=true -Dfindbugs.skip=true -Dspotbugs.skip=true -Dcheckstyle.skip=true
# exec gosu builder mvn eclipse:eclipse