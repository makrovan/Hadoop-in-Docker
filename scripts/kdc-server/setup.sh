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
    # Default Kerberos version 5 realm: DOCKER.NET
    # Kerberos servers for your realm: kdc-server.docker.net
    # Administrative server for your Kerberos realm: kdc-server.docker.net

echo "*/admin@DOCKER.NET    *" >> /etc/krb5kdc/kadm5.acl

# ----------------------------------------------------------------------------------------------------------------
# Используем утилиту kdb5_ldap_util для создания области:
kdb5_ldap_util -D cn=admin,dc=docker,dc=net create -subtrees dc=docker,dc=net -r DOCKER.NET -s -H ldaps://ldap-server.docker.net 
#Password for "cn=admin,dc=docker,dc=net": hadoop
#Enter KDC database master key: hadoop
#Enter DN of Kerberos container: cn=krbContainer,dc=docker,dc=net

# Создаем тайник для пароля, используемого для подключения к LDAP серверу. Этот пароль используется опциями ldap_kdc_dn и ldap_kadmin_dn в /etc/krb5.conf:
mkdir -p /etc/security/keyfiles
rm -f /etc/security/keyfiles/service.keyfile
kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/security/keyfiles/service.keyfile uid=kdc-service,dc=docker,dc=net
#Password for "cn=admin,dc=docker,dc=net": hadoop
#Password for "uid=kdc-service,dc=docker,dc=net": hadoop
kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/security/keyfiles/service.keyfile uid=kadmin-service,dc=docker,dc=net
#Password for "cn=admin,dc=docker,dc=net": hadoop
#Password for "uid=kdc-service,dc=docker,dc=net": hadoop

rm -f /etc/krb5.conf
cp /tmp/krb5.conf /etc/krb5.conf
