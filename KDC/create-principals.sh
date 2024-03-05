#!/bin/bash

cd /root/keytabs
rm *.keytab

kadmin.local -q 'addprinc -randkey nn/hadoop-master@REALM.TLD'
kadmin.local -q 'addprinc -randkey dn/hadoop-worker1@REALM.TLD'
kadmin.local -q 'addprinc -randkey dn/hadoop-worker2@REALM.TLD'
kadmin.local -q 'addprinc -randkey rm/hadoop-rmanager@REALM.TLD'
kadmin.local -q 'addprinc -randkey nm/hadoop-worker1@REALM.TLD'
kadmin.local -q 'addprinc -randkey nm/hadoop-worker2@REALM.TLD'
kadmin.local -q 'addprinc -randkey rm/hadoop-proxy@REALM.TLD'
kadmin.local -q 'addprinc -randkey jhs/hadoop-history@REALM.TLD'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-master@REALM.TLD'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-worker1@REALM.TLD'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-worker2@REALM.TLD'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-rmanager@REALM.TLD'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-history@REALM.TLD'
kadmin.local -q 'addprinc -randkey HTTP/hadoop-proxy@REALM.TLD'

kadmin.local -q 'ktadd -norandkey -k dn.service.keytab dn/hadoop-worker1@REALM.TLD dn/hadoop-worker2@REALM.TLD'
kadmin.local -q 'ktadd -norandkey -k jhs.service.keytab jhs/hadoop-history@REALM.TLD'
kadmin.local -q 'ktadd -norandkey -k nm.service.keytab nm/hadoop-worker1@REALM.TLD nm/hadoop-worker2@REALM.TLD'
kadmin.local -q 'ktadd -norandkey -k nn.service.keytab nn/hadoop-master@REALM.TLD'
kadmin.local -q 'ktadd -norandkey -k rm.service.keytab rm/hadoop-rmanager@REALM.TLD rm/hadoop-proxy@REALM.TLD'
kadmin.local -q 'ktadd -norandkey -k spnego.service.keytab nn/hadoop-master@REALM.TLD nm/hadoop-worker1@REALM.TLD nm/hadoop-worker2@REALM.TLD'
kadmin.local -q 'ktadd -norandkey -k HTTP.service.keytab HTTP/hadoop-master@REALM.TLD HTTP/hadoop-worker1@REALM.TLD HTTP/hadoop-worker2@REALM.TLD HTTP/hadoop-rmanager@REALM.TLD HTTP/hadoop-history@REALM.TLD HTTP/hadoop-proxy@REALM.TLD'