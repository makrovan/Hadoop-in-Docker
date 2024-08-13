#!/bin/bash

# ждем kdc, который загружается после ldap
kinit -k -t /etc/security/keytab/my.keytab hdfs@DOCKER.NET 
while [ $? -ne 0 ]
do
    sleep 5
    echo "waiting kinit..."
    kinit -k -t /etc/security/keytab/my.keytab hdfs@DOCKER.NET 
done

if [ `ls /usr/local/hadoop/data/nameNode/ | wc -l` -eq 0 ]; then
    /usr/local/hadoop/bin/hdfs namenode -format -force
    echo "formated!!!"

    if [ $? -eq 0 ]
    then
        /tmp/init-filesystem.sh &
        #kdestroy called in init-filesystem.sh
    fi
fi

/usr/local/hadoop/bin/hdfs namenode