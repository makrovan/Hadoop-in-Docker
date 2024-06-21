#!/bin/bash

#https://ubuntu.com/server/docs/ldap-and-transport-layer-security-tls

apt update && apt install slapd ldap-utils gnutls-bin ssl-cert ca-certificates rsyslog krb5-kdc-ldap nano schema2ldif -y 
    #Administrator password: hadoop

    #Default Kerberos version 5 realm: DOCKER.NET
    #Kerberos servers for your realm: kdc-server.docker.net
    #Administrative server for your Kerberos realm: kdc-server.docker.net
certtool --generate-privkey --bits 4096 --outfile /etc/ssl/private/mycakey.pem
echo "cn = Docker Net
ca
cert_signing_key
expiration_days = 3650" >> /etc/ssl/ca.info
certtool --generate-self-signed --load-privkey /etc/ssl/private/mycakey.pem --template /etc/ssl/ca.info --outfile /usr/local/share/ca-certificates/mycacert.crt
update-ca-certificates

certtool --generate-privkey --bits 2048 --outfile /etc/ldap/ldap01_slapd_key.pem
echo "organization = Docker Net
cn = ldap-server.docker.net
tls_www_server
encryption_key
signing_key
expiration_days = 365" >> /etc/ssl/ldap01.info
certtool --generate-certificate --load-privkey /etc/ldap/ldap01_slapd_key.pem --load-ca-certificate /etc/ssl/certs/mycacert.pem --load-ca-privkey /etc/ssl/private/mycakey.pem --template /etc/ssl/ldap01.info --outfile /etc/ldap/ldap01_slapd_cert.pem
echo "dn: cn=config
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ssl/certs/mycacert.pem
-
add: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/ldap01_slapd_cert.pem
-
add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/ldap01_slapd_key.pem" >> certinfo.ldif

slapd -h "ldap:// ldapi://"
ldapmodify -Y EXTERNAL -H ldapi:/// -f certinfo.ldif

mkdir kdc-ssl
cd kdc-ssl
certtool --generate-privkey --bits 2048 --outfile kdc_slapd_key.pem
echo "organization = Docker Net
cn = kdc.docker.net
tls_www_server
encryption_key
signing_key
expiration_days = 365" >> kdc.info
certtool --generate-certificate --load-privkey kdc_slapd_key.pem --load-ca-certificate /etc/ssl/certs/mycacert.pem --load-ca-privkey /etc/ssl/private/mycakey.pem --template kdc.info --outfile kdc_slapd_cert.pem
cp /etc/ssl/certs/mycacert.pem .

cd ..
echo "dn: cn=config
changetype: modify
replace: olcLogLevel
olcLogLevel: stats" >> logging.ldif
ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f logging.ldif

nano /etc/ldap/schema/kerberos.schema   #добавляем код
ldap-schema-manager -i kerberos.schema
#ldapsearch -QLLLY EXTERNAL -H ldapi:/// -b cn=schema,cn=config dn | grep -i kerberos
#ldapsearch -QLLLY EXTERNAL -H ldapi:/// -b cn={4}kerberos,cn=schema,cn=config | grep NAME | cut -d' ' -f5 | sort
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcDbIndex
olcDbIndex: krbPrincipalName eq,pres,sub
EOF
ldapadd -x -D cn=admin,dc=docker,dc=net -W <<EOF
dn: uid=kdc-service,dc=docker,dc=net
uid: kdc-service
objectClass: account
objectClass: simpleSecurityObject
userPassword: {CRYPT}x
description: Account used for the Kerberos KDC

dn: uid=kadmin-service,dc=docker,dc=net
uid: kadmin-service
objectClass: account
objectClass: simpleSecurityObject
userPassword: {CRYPT}x
description: Account used for the Kerberos Admin server
EOF
    #Enter LDAP Password: hadoop
ldappasswd -x -D cn=admin,dc=docker,dc=net -W -S uid=kdc-service,dc=docker,dc=net 
    #New password: hadoop; 
    #Enter LDAP Password: hadoop
#ldapwhoami -x -D uid=kdc-service,dc=docker,dc=net -W
    #Enter LDAP Password: hadoop
ldappasswd -x -D cn=admin,dc=docker,dc=net -W -S uid=kadmin-service,dc=docker,dc=net
    #New password: hadoop; 
    #Enter LDAP Password: hadoop
#ldapwhoami -x -D uid=kadmin-service,dc=docker,dc=net -W
    #Enter LDAP Password: hadoop
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcAccess
olcAccess: {2}to attrs=krbPrincipalKey
  by anonymous auth
  by dn.exact="uid=kdc-service,dc=docker,dc=net" read
  by dn.exact="uid=kadmin-service,dc=docker,dc=net" write
  by self write
  by * none
-
add: olcAccess
olcAccess: {3}to dn.subtree="cn=krbContainer,dc=docker,dc=net"
  by dn.exact="uid=kdc-service,dc=docker,dc=net" read
  by dn.exact="uid=kadmin-service,dc=docker,dc=net" write
  by * none
EOF
#slapcat -b cn=config

kdb5_ldap_util -D cn=admin,dc=docker,dc=net create -subtrees dc=docker,dc=net -r DOCKER.NET -s -H ldapi:/// 
    #Password for "cn=admin,dc=docker,dc=net": hadoop
    #Enter KDC database master key: hadoop
    # Enter DN of Kerberos container: cn=krbContainer,dc=docker,dc=net
kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kdc-service,dc=docker,dc=net
    #Password for "cn=admin,dc=docker,dc=net": hadoop
    #Password for "uid=kdc-service,dc=docker,dc=net": hadoop
kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kadmin-service,dc=docker,dc=net
    #Password for "cn=admin,dc=docker,dc=net": hadoop
    #Password for "uid=kdc-service,dc=docker,dc=net": hadoop

apt remove schema2ldif krb5-kdc-ldap nano ldap-utils gnutls-bin ca-certificates ssl-cert -y