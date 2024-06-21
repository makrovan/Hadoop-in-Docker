#!/bin/bash

while [ `ls /etc/krb5kdc/keyfiles/kdc-ssl | wc -l` -eq 0 ]
do
    sleep 5
    echo "waiting /etc/krb5kdc/keyfiles/kdc-ssl..."
done

    cd /etc/krb5kdc/keyfiles/kdc-ssl
    mv kdc_slapd_cert.pem kdc_slapd_key.pem /etc/ldap
    mv mycacert.pem /usr/local/share/ca-certificates/mycacert.crt
    update-ca-certificates
    mv /etc/krb5kdc/keyfiles/stash /etc/krb5kdc/

# kadmind
# wait /tmp/create-principals.sh
krb5kdc
while [ $? -ne 0 ]
do
    sleep 5
    echo "waiting krb5kdc..."
    krb5kdc
done
/tmp/kdc-create-principals.sh
kadmind -nofork