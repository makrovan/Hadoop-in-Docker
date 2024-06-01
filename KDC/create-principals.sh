#!/bin/bash

cd /root/keytabs
rm *.keytab

kadmin.local -q 'addprinc -randkey nn/hadoop-master.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey dn/hadoop-worker1.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey dn/hadoop-worker2.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey rm/hadoop-rmanager.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey nm/hadoop-worker1.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey nm/hadoop-worker2.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey rm/hadoop-proxy.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey jhs/hadoop-history.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-master.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-worker1.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-worker2.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-rmanager.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-history.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-proxy.docker.net@DOCKER.NET'

kadmin.local -q 'ktadd -norandkey -k dn.service.keytab dn/hadoop-worker1.docker.net@DOCKER.NET dn/hadoop-worker2.docker.net@DOCKER.NET'
kadmin.local -q 'ktadd -norandkey -k jhs.service.keytab jhs/hadoop-history.docker.net@DOCKER.NET'
kadmin.local -q 'ktadd -norandkey -k nm.service.keytab nm/hadoop-worker1.docker.net@DOCKER.NET nm/hadoop-worker2.docker.net@DOCKER.NET'
kadmin.local -q 'ktadd -norandkey -k nn.service.keytab nn/hadoop-master.docker.net@DOCKER.NET'
kadmin.local -q 'ktadd -norandkey -k rm.service.keytab rm/hadoop-rmanager.docker.net@DOCKER.NET rm/hadoop-proxy.docker.net@DOCKER.NET'
kadmin.local -q 'ktadd -norandkey -k spnego.service.keytab nn/hadoop-master.docker.net@DOCKER.NET nm/hadoop-worker1.docker.net@DOCKER.NET nm/hadoop-worker2.docker.net@DOCKER.NET'
kadmin.local -q 'ktadd -norandkey -k HTTP.service.keytab HTTP/hadoop-master.docker.net@DOCKER.NET HTTP/hadoop-worker1.docker.net@DOCKER.NET HTTP/hadoop-worker2.docker.net@DOCKER.NET HTTP/hadoop-rmanager.docker.net@DOCKER.NET HTTP/hadoop-history.docker.net@DOCKER.NET HTTP/hadoop-proxy.docker.net@DOCKER.NET'

#echo "hdfs@DOCKER.NET * HTTP/hadoop-master.docker.net@DOCKER.NET" >> /etc/krb5kdc/kadm5.acl

# echo "[logging]
#     default = FILE:/var/log/krb5.log
#     kdc = FILE:/var/log/krb5kdc.log
#     admin_server = FILE:/var/log/kadmin.log
# " >> /etc/krb5.conf

# echo "
# [logging]
#     default = FILE:/var/log/krb5.log
#     kdc = FILE:/var/log/krb5kdc.log
#     admin_server = FILE:/var/log/kadmin.log
# " >> /etc/krb5kdc/kdc.conf

# /etc/init.d/krb5-admin-server restart
# /etc/init.d/krb5-kdc restart