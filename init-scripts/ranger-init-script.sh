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

cp -f /tmp/admin/install.properties .
./setup.sh
./set_globals.sh
/usr/local/ranger-admin/ews/start-ranger-admin.sh

cd /etc/krb5kdc/keyfiles/kdc-ssl
cp mycacert.pem /usr/local/share/ca-certificates/mycacert.crt
update-ca-certificates

cd /usr/local
tar zxf ranger-2.4.0-usersync.tar.gz
ln -s ranger-2.4.0-usersync ranger-usersync
cd ranger-usersync

cp -f /tmp/usersync/install.properties .
mkdir -p /var/log/ranger-usersync
chown ranger /var/log/ranger-usersync
chgrp ranger /var/log/ranger-usersync
./setup.sh
cd /usr/bin
ln -sf /usr/local/ranger-usersync/start.sh ranger-usersync-start
ranger-usersync-start

# pid="$(pidof java)"
# while [ -e /proc/$pid ]; do sleep 5; done
while true; do sleep 5; done

# Ranger Admin authentication can be configured to use LDAP or Linux system. Consider configuring one of them in production environment. TBD: Provide link to configure LDAP or Linux for authentication
# Review database capacity for Audit database. It can grow dramatically in HBase or high volume environment. TBD: Provide link DB capacity planning