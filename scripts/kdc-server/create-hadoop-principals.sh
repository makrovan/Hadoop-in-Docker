#!/bin/bash
set -x

mkdir -p /etc/security/keytabs
rm -f /etc/security/keytabs/*
cd /etc/security/keytabs

#services principals
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

#user principals
kadmin.local -q 'addprinc -randkey hdfs@DOCKER.NET'
kadmin.local -q 'addprinc -randkey yarn@DOCKER.NET'
kadmin.local -q 'addprinc -randkey mapred@DOCKER.NET'
kadmin.local -q 'ktadd -norandkey -k my.keytab hdfs@DOCKER.NET yarn@DOCKER.NET mapred@DOCKER.NET'


#ranger principals
# https://cwiki.apache.org/confluence/display/RANGER/Ranger+installation+in+Kerberized++Environment
kadmin.local -q 'addprinc -randkey HTTP/hadoop-ranger.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey rangeradmin/hadoop-ranger.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey rangerlookup/hadoop-ranger.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey rangerusersync/hadoop-ranger.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey solr/hadoop-solr.docker.net@DOCKER.NET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-solr.docker.net@DOCKER.NET'
kadmin.local -q 'ktadd -norandkey -k ranger.keytab HTTP/hadoop-ranger.docker.net@DOCKER.NET rangeradmin/hadoop-ranger.docker.net@DOCKER.NET rangerlookup/hadoop-ranger.docker.net@DOCKER.NET rangerusersync/hadoop-ranger.docker.net@DOCKER.NET solr/hadoop-solr.docker.net@DOCKER.NET HTTP/hadoop-solr.docker.net@DOCKER.NET'

chmod +r ./*
