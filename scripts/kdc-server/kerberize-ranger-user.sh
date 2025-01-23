#!/bin/bash
set -x

# https://ubuntu.com/server/docs/how-to-set-up-kerberos-with-openldap-backend
kadmin.local -q "addprinc -x dn=uid=ldapuser,ou=users,dc=hadoopnet -pw pass ldapuser"
for i in $(seq 4); do 
    kadmin.local -q "addprinc -x dn=uid=ldapuser${i},ou=users,dc=hadoopnet -pw pass${i} ldapuser${i}"
done
