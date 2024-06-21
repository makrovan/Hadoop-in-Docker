#!/bin/bash

rm /etc/krb5kdc/keyfiles/*
mv /etc/krb5kdc/service.keyfile /etc/krb5kdc/keyfiles/service.keyfile
while [ $? -ne 0 ]
do
    sleep 5
    echo "waiting service.keyfile..."
    mv /etc/krb5kdc/service.keyfile /etc/krb5kdc/keyfiles/
done

mv /etc/krb5kdc/stash /etc/krb5kdc/keyfiles/
cp -r /kdc-ssl /etc/krb5kdc/keyfiles/
echo "ldap starting..."
rsyslogd
slapd -h "ldaps://" -d 0