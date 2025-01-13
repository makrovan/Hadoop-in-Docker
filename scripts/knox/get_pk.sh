#!/bin/bash
set -x

rm /etc/kpk/knox_pubkey
keytool -export -alias $(hostname) -keypass hadoop -keystore /tmp/ssl/keystore.jks -storepass hadoop -file /tmp/ssl/sso_publickey.pem
openssl x509 -pubkey -noout -in /tmp/ssl/sso_publickey.pem -out /etc/kpk/knox_pk
sed -i '/^--.*--$/d' /etc/kpk/knox_pk
cat /etc/kpk/knox_pk | tr -d '\n' > /etc/kpk/knox_pubkey
rm /tmp/ssl/sso_publickey.pem
rm /etc/kpk/knox_pk