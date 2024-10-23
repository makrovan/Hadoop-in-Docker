#!/bin/bash
set -x

# ждем корневой сертификат
while [ ! -f /etc/CA/mycacert.pem ]
do
    sleep 5
    echo "waiting /etc/CA/mycacert.pem..."
done

# если root, то добавляем корневой сертификат в список доверенных (нужен для ldaps)
if [ $(id -u) = 0 ]; then
    cp /etc/CA/mycacert.pem /usr/local/share/ca-certificates/mycacert.crt
    update-ca-certificates
fi

# создаем ключи для https/ssl - соединений
# https://kuzevanov.ru/linux/commands-java-keytool.html
mkdir -p /tmp/ssl
cd /tmp/ssl
# Создайте хранилище ключей Java и пару ключей
keytool -genkey -alias $(hostname) -keyalg RSA -keysize 2048 -keystore keystore.jks -dname "CN=$(hostname)" -keypass hadoop -storepass hadoop
# Создайте запрос на подпись сертификата (CSR) для существующего хранилища ключей Java
keytool -certreq -alias $(hostname) -keystore keystore.jks -file keystore.csr -storepass hadoop

# Корневой сертификат в формат JKS:
if [ ! -f /etc/CA/mycacert.jks ]; then
    keytool -import -alias $(hostname) -file /etc/CA/mycacert.pem -keypass hadoop -keystore /etc/CA/mycacert.jks -storepass hadoop -noprompt
    # keytool -v -list -storetype jks -keystore root.jks -storepass ranger
fi
# cp /etc/CA/mycacert.jks .

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
openssl x509 -req -days 365 -in keystore.csr -CA /etc/CA/mycacert.pem -CAkey /etc/CA/mycakey.pem -CAcreateserial -out keystore.crt
# Импорт подписанного первичного сертификата в существующее хранилище ключей Java
keytool -import -trustcacerts -alias $(hostname) -file keystore.crt -keystore keystore.jks -storepass hadoop
rm keystore.csr
rm keystore.crt
