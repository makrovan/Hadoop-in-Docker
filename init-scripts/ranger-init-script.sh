#!/bin/bash

# https://cwiki.apache.org/confluence/display/RANGER/Ranger+Installation+Guide#RangerInstallationGuide-Install/ConfigureRangerAdmin
cd /usr/local
tar zxf ranger-2.4.0-admin.tar.gz
ln -s ranger-2.4.0-admin ranger-admin
cd ranger-admin

echo "kinit checking..."
kinit -k -t /etc/security/keytab/ranger.keytab rangeradmin/hadoop-ranger.docker.net@DOCKER.NET 
while [ $? -ne 0 ]
do
    sleep 5
    echo "kinit waiting..."
    kinit -k -t /etc/security/keytab/ranger.keytab rangeradmin/hadoop-ranger.docker.net@DOCKER.NET
done
kdestroy

cp -f /tmp/install.properties .
./setup.sh
./set_globals.sh
/usr/local/ranger-admin/ews/start-ranger-admin.sh

pid="$(pidof java)"
while [ -e /proc/$pid ]; do sleep 5; done

# Ranger Admin authentication can be configured to use LDAP or Linux system. Consider configuring one of them in production environment. TBD: Provide link to configure LDAP or Linux for authentication
# Review database capacity for Audit database. It can grow dramatically in HBase or high volume environment. TBD: Provide link DB capacity planning