#!/bin/bash
set -x

#https://ubuntu.com/server/docs/how-to-set-up-kerberos-with-openldap-backend

# waiting for ldap-server...
while [ ! -f /etc/sync/ldap_started ]
do
    sleep 5
    echo "waiting /etc/sync/ldap_started..."
done

cp /etc/CA/mycacert.pem /usr/local/share/ca-certificates/mycacert.crt
update-ca-certificates

apt install -y krb5-kdc-ldap krb5-admin-server
    # Default Kerberos version 5 realm: HADOOPNET
    # Kerberos servers for your realm: kdc-server.hadoopnet
    # Administrative server for your Kerberos realm: kdc-server.hadoopnet

echo "*/admin@HADOOPNET    *" >> /etc/krb5kdc/kadm5.acl

# ----------------------------------------------------------------------------------------------------------------
# Используем утилиту kdb5_ldap_util для создания области:
kdb5_ldap_util -D cn=admin,dc=hadoopnet create -subtrees dc=hadoopnet -r HADOOPNET -s -H ldaps://ldap-server.hadoopnet 
#Password for "cn=admin,dc=hadoopnet": hadoop
#Enter KDC database master key: hadoop
#Enter DN of Kerberos container: cn=krbContainer,dc=hadoopnet

# Создаем тайник для пароля, используемого для подключения к LDAP серверу. Этот пароль используется опциями ldap_kdc_dn и ldap_kadmin_dn в /etc/krb5.conf:
mkdir -p /etc/security/keyfiles
rm -f /etc/security/keyfiles/service.keyfile
kdb5_ldap_util -D cn=admin,dc=hadoopnet stashsrvpw -f /etc/security/keyfiles/service.keyfile uid=kdc-service,dc=hadoopnet
#Password for "cn=admin,dc=hadoopnet": hadoop
#Password for "uid=kdc-service,dc=hadoopnet": hadoop
kdb5_ldap_util -D cn=admin,dc=hadoopnet stashsrvpw -f /etc/security/keyfiles/service.keyfile uid=kadmin-service,dc=hadoopnet
#Password for "cn=admin,dc=hadoopnet": hadoop
#Password for "uid=kdc-service,dc=hadoopnet": hadoop

rm -f /etc/krb5.conf
cp /tmp/krb5.conf /etc/krb5.conf
