#!/bin/bash
set -x

mkdir -p /etc/security/keytabs
rm -f /etc/security/keytabs/*
cd /etc/security/keytabs

#services principals
kadmin.local -q 'addprinc -randkey nn/hadoop-master.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey dn/hadoop-worker1.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey dn/hadoop-worker2.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey rm/hadoop-rmanager.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey nm/hadoop-worker1.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey nm/hadoop-worker2.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey rm/hadoop-proxy.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey jhs/hadoop-history.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-master.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-worker1.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-worker2.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-rmanager.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-history.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-proxy.hadoopnet@HADOOPNET'

kadmin.local -q 'ktadd -norandkey -k dn.service.keytab dn/hadoop-worker1.hadoopnet@HADOOPNET dn/hadoop-worker2.hadoopnet@HADOOPNET'
kadmin.local -q 'ktadd -norandkey -k jhs.service.keytab jhs/hadoop-history.hadoopnet@HADOOPNET'
kadmin.local -q 'ktadd -norandkey -k nm.service.keytab nm/hadoop-worker1.hadoopnet@HADOOPNET nm/hadoop-worker2.hadoopnet@HADOOPNET'
kadmin.local -q 'ktadd -norandkey -k nn.service.keytab nn/hadoop-master.hadoopnet@HADOOPNET'
kadmin.local -q 'ktadd -norandkey -k rm.service.keytab rm/hadoop-rmanager.hadoopnet@HADOOPNET rm/hadoop-proxy.hadoopnet@HADOOPNET'
kadmin.local -q 'ktadd -norandkey -k spnego.service.keytab nn/hadoop-master.hadoopnet@HADOOPNET nm/hadoop-worker1.hadoopnet@HADOOPNET nm/hadoop-worker2.hadoopnet@HADOOPNET'
kadmin.local -q 'ktadd -norandkey -k HTTP.service.keytab HTTP/hadoop-master.hadoopnet@HADOOPNET HTTP/hadoop-worker1.hadoopnet@HADOOPNET HTTP/hadoop-worker2.hadoopnet@HADOOPNET HTTP/hadoop-rmanager.hadoopnet@HADOOPNET HTTP/hadoop-history.hadoopnet@HADOOPNET HTTP/hadoop-proxy.hadoopnet@HADOOPNET'

#user principals
kadmin.local -q 'addprinc -randkey hdfs@HADOOPNET'
kadmin.local -q 'addprinc -randkey yarn@HADOOPNET'
kadmin.local -q 'addprinc -randkey mapred@HADOOPNET'
kadmin.local -q 'ktadd -norandkey -k my.keytab hdfs@HADOOPNET yarn@HADOOPNET mapred@HADOOPNET'


#ranger principals
# https://cwiki.apache.org/confluence/display/RANGER/Ranger+installation+in+Kerberized++Environment
kadmin.local -q 'addprinc -randkey HTTP/hadoop-ranger.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey rangeradmin/hadoop-ranger.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey rangerlookup/hadoop-ranger.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey rangerusersync/hadoop-ranger.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey solr/hadoop-solr.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-solr.hadoopnet@HADOOPNET'
kadmin.local -q 'ktadd -norandkey -k ranger.keytab HTTP/hadoop-ranger.hadoopnet@HADOOPNET rangeradmin/hadoop-ranger.hadoopnet@HADOOPNET rangerlookup/hadoop-ranger.hadoopnet@HADOOPNET rangerusersync/hadoop-ranger.hadoopnet@HADOOPNET solr/hadoop-solr.hadoopnet@HADOOPNET HTTP/hadoop-solr.hadoopnet@HADOOPNET'

kadmin.local -q 'addprinc -randkey knox/hadoop-knox.hadoopnet@HADOOPNET'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-knox.hadoopnet@HADOOPNET'
kadmin.local -q 'ktadd -norandkey -k knox.service.keytab HTTP/hadoop-knox.hadoopnet@HADOOPNET knox/hadoop-knox.hadoopnet@HADOOPNET'
chmod +r ./*
