#!/bin/bash

# https://ubuntu.com/server/docs/ldap-and-transport-layer-security-tls
# https://ubuntu.com/server/docs/how-to-set-up-kerberos-with-openldap-backend

# kdc-server будет ждать, пока в этой папке не появится корневой сертификат
rm -rf /etc/krb5kdc/keyfiles/*

# docker run -it --hostname ldap-server.docker.net ubuntu /bin/bash
apt update && apt install -y slapd gnutls-bin ssl-cert ca-certificates rsyslog schema2ldif 
#Administrator password: hadoop

#Default Kerberos version 5 realm: DOCKER.NET
#Kerberos servers for your realm: kdc-server.docker.net
#Administrative server for your Kerberos realm: kdc-server.docker.net

# -------------------------Центр сертификации---------------------------------------------------------------------------------
# Здесь мы организуем свой собственный Центр сертификатов (Certificate Authority - CA) и затем создадим и подпишем сертификат нашего LDAP сервера от имени этого CA.

# Создаем секретный ключ Центра сертификатов:
certtool --generate-privkey --bits 4096 --outfile /etc/ssl/private/mycakey.pem
# openssl genrsa -aes256 -out private/rootca.key 4096

# Создаем временный файл /etc/ssl/ca.info для определения CA:
echo "cn = Docker Net
ca
cert_signing_key
expiration_days = 3650" >> /etc/ssl/ca.info

# Создаем самоподписанный сертификат центра:
certtool --generate-self-signed --load-privkey /etc/ssl/private/mycakey.pem --template /etc/ssl/ca.info --outfile /usr/local/share/ca-certificates/mycacert.crt
# Сейчас мы можем выпустить корневой сертификат удостоверяющего центра, подписав его закрытым ключом rootca.key:
# openssl req -sha256 -new -x509 -days 3650 -extensions v3_ca \
#  -key private/rootca.key -out certs/rootca.crt \
#  -subj /C=RU/ST=Moscow/L=Moscow/O=ExampleInc/OU=ITdept/CN=ca-server/emailAddress=support@example.com

update-ca-certificates


# --------------------------LDAP-сервер-сертификат (ключи)--------------------------------------------------------------------------------
# Создаем секретный ключ для сервера (provider):
certtool --generate-privkey --bits 2048 --outfile /etc/ldap/ldap01_slapd_key.pem
# openssl genrsa -out private/ldap-srv.example.com.key 4096

# Создаем информационный файл /etc/ssl/ldap01.info
echo "organization = Docker Net
cn = ldap-server.docker.net
tls_www_server
encryption_key
signing_key
expiration_days = 365" >> /etc/ssl/ldap01.info

# Создаем серверный сертификат:
certtool --generate-certificate \
--load-privkey /etc/ldap/ldap01_slapd_key.pem \
--load-ca-certificate /etc/ssl/certs/mycacert.pem \
--load-ca-privkey /etc/ssl/private/mycakey.pem \
--template /etc/ssl/ldap01.info \
--outfile /etc/ldap/ldap01_slapd_cert.pem
# Сгенерируем запрос на подпись сертификата. Наименование организации (ExampleInc) должно совпадать с наименованием в корневом сертификате УЦ:
# openssl req -sha256 -new \
#         -key private/ldap-srv.example.com.key -out certs/ldap-srv.example.com.csr \
#         -subj /C=RU/ST=Moscow/L=Moscow/O=ExampleInc/OU=ITdept/CN=ldap-srv.example.com/emailAddress=support@example.com
# Следующим шагом должно быть подписание запроса CSR существующим доверенным удостоверяющим центром (например, VeriSign) в обмен на деньги. 
# openssl ca -extensions usr_cert -notext -md sha256 \
#  -keyfile private/rootca.key -cert certs/rootca.crt \
#  -in certs/ldap-srv.example.com.csr -out certs/ldap-srv.example.com.crt

# Создадим LDIF-файл для внесения в каталог конфигурации TLS (Этими записи говорят демону slapd, где лежит его сертификат и ключ, 
# где лежит корневой сертификат УЦ и что от клиентов требовать наличие сертификата не нужно.)
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
# Загрузим конфигурацию TLS в наш каталог:
ldapmodify -Y EXTERNAL -H ldapi:/// -f certinfo.ldif

# ---------------------------Kerberos-клиент-сертификат (ключи)-------------------------------------------------------------------------------
# cd kdc-ssl

# Создаем секретный ключ потребителя (consumer):
# certtool --generate-privkey --bits 2048 --outfile kdc_slapd_key.pem

# Создаем информационный файл ldap02.info для сервера Потребителя
# echo "organization = Docker Net
# cn = kdc.docker.net
# tls_www_server
# encryption_key
# signing_key
# expiration_days = 365" >> kdc.info

# Создаем сертификат Потребителя:
# certtool --generate-certificate \
# --load-privkey kdc_slapd_key.pem \
# --load-ca-certificate /etc/ssl/certs/mycacert.pem \
# --load-ca-privkey /etc/ssl/private/mycakey.pem \
# --template kdc.info \
# --outfile kdc_slapd_cert.pem

# -----------------------------Настройка LDAP-----------------------------------------------------------------------------
# cd ..
# Настройка системы журналированияЖ
echo "dn: cn=config
changetype: modify
replace: olcLogLevel
olcLogLevel: stats" >> logging.ldif
ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f logging.ldif

cp /tmp/kerberos.schema /etc/ldap/schema/   #добавляем код
# Загрузите новую схему:
ldap-schema-manager -i kerberos.schema
#ldapsearch -QLLLY EXTERNAL -H ldapi:/// -b cn=schema,cn=config dn | grep -i kerberos
#ldapsearch -QLLLY EXTERNAL -H ldapi:/// -b cn={4}kerberos,cn=schema,cn=config | grep NAME | cut -d' ' -f5 | sort

# Добавьте индекс для атрибута krb5principalname:
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
add: olcDbIndex
olcDbIndex: krbPrincipalName eq,pres,sub
EOF

# Let’s create LDAP entries for the Kerberos administrative entities that will contact the OpenLDAP server to perform operations:
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

# To change the password to something valid, you can now use ldappasswd:
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

# В конце обновите списки контроля доступа (ACL):
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

apt remove -y schema2ldif gnutls-bin ca-certificates ssl-cert

# На клиенте достаточно только корневого сертификата для проверки сертификата LDAP-сервера.
mkdir /kdc-ssl
cp /etc/ssl/certs/mycacert.pem /kdc-ssl
cp -r /kdc-ssl /etc/krb5kdc/keyfiles/

# Для генерации подписанных сертификатов выкладываем также закрытый ключ нашего центра сертификации
mkdir /private
cp /etc/ssl/private/mycakey.pem /private
cp -r /private /etc/krb5kdc/keyfiles/