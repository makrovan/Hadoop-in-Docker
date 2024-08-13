#!/bin/bash

#https://ubuntu.com/server/docs/how-to-set-up-kerberos-with-openldap-backend

rm /root/keytabs/*.keytab

apt-get update && apt install ca-certificates -y
while [ `ls /etc/krb5kdc/keyfiles/kdc-ssl | wc -l` -eq 0 ]
do
    sleep 5
    echo "waiting /etc/krb5kdc/keyfiles/kdc-ssl..."
done

cp /etc/krb5kdc/keyfiles/kdc-ssl/mycacert.pem /usr/local/share/ca-certificates/mycacert.crt
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
kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/krb5kdc/keyfiles/service.keyfile uid=kdc-service,dc=docker,dc=net
#Password for "cn=admin,dc=docker,dc=net": hadoop
#Password for "uid=kdc-service,dc=docker,dc=net": hadoop
kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/krb5kdc/keyfiles/service.keyfile uid=kadmin-service,dc=docker,dc=net
#Password for "cn=admin,dc=docker,dc=net": hadoop
#Password for "uid=kdc-service,dc=docker,dc=net": hadoop

cp /tmp/krb5.conf /etc/krb5.conf