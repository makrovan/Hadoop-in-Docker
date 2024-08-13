#!/bin/bash

# ждем пока стартанет ldap-сервер и выложит в общий доступ корневой сертификат
apt install -y ca-certificates
while [ `ls /etc/krb5kdc/keyfiles/kdc-ssl | wc -l` -eq 0 ]
do
    sleep 5
    echo "waiting /etc/krb5kdc/keyfiles/kdc-ssl..."
done

cp /etc/krb5kdc/keyfiles/kdc-ssl/mycacert.pem /usr/local/share/ca-certificates/mycacert.crt
update-ca-certificates

mkdir /usr/local/hadoop/my_ca
cd /usr/local/hadoop/my_ca

# https://kuzevanov.ru/linux/commands-java-keytool.html

# Создайте хранилище ключей Java и пару ключей
keytool -genkey -alias $(hostname) -keyalg RSA -keysize 2048 -keystore .keystore -dname "CN=$(hostname)" -keypass hadoop -storepass hadoop
# Создайте запрос на подпись сертификата (CSR) для существующего хранилища ключей Java
keytool -certreq -alias $(hostname) -keystore .keystore -file hadoop.csr -storepass hadoop

cp /etc/krb5kdc/keyfiles/private/mycakey.pem .
cp /usr/local/share/ca-certificates/mycacert.crt .

# https://www.golinuxcloud.com/add-x509-extensions-to-certificate-openssl/
# Scenario-2: Add X.509 extensions to Certificate Signing Request (CSR)
echo "[ req ]
distinguished_name  = req_distinguished_name
policy              = policy_match
x509_extensions     = user_crt
req_extensions      = v3_req

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = IN
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = State or Province Name (full name) ## Print this message
stateOrProvinceName_default     = KARNATAKA ## This is the default value
localityName                    = Locality Name (eg, city) ## Print this message
localityName_default            = BANGALORE ## This is the default value
0.organizationName              = Organization Name (eg, company) ## Print this message
0.organizationName_default      = GoLinuxCloud ## This is the default value
organizationalUnitName          = Organizational Unit Name (eg, section) ## Print this message
organizationalUnitName_default  = Admin ## This is the default value
commonName                      = Common Name (eg, your name or your server hostname) ## Print this message
commonName_max                  = 64
emailAddress                    = Email Address ## Print this message
emailAddress_max                = 64

[ user_crt ]
nsCertType              = client, server, email
nsComment               = "OpenSSL Generated Certificate"
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer

[ v3_req ]
basicConstraints        = CA:FALSE
extendedKeyUsage        = serverAuth, clientAuth, codeSigning, emailProtection
keyUsage                = nonRepudiation, digitalSignature, keyEncipherment" >> openssl.cnf
# Generate server certificate using CSR and rootca certificate:
openssl x509 -req -days 365 -in hadoop.csr -CA mycacert.crt -CAkey mycakey.pem -CAcreateserial -out hadoop.crt
# Импорт подписанного первичного сертификата в существующее хранилище ключей Java
keytool -import -trustcacerts -alias $(hostname) -file hadoop.crt -keystore .keystore -storepass hadoop

chown hdfs:hadoop .keystore
chmod 640 .keystore