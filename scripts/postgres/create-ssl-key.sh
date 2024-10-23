#!/bin/bash
set -x

# ждем корневой сертификат
while [[ ! -f /etc/CA/mycacert.pem || ! -f /etc/CA/mycakey.pem ]]
do
    sleep 5
    echo "waiting /etc/CA/mycacert.pem & /etc/CA/mycakey.pem..."
done

# https://www.postgresql.org/docs/current/ssl-tcp.html#SSL-SERVER-FILES
echo "making ssl key for connecting to DB..."
cd /var/lib/postgresql/data
cp /etc/CA/mycacert.pem .
cp /etc/CA/mycakey.pem .
# openssl req -new -nodes -text -out root.csr -keyout root.key -subj "/CN=$(hostname)"
# openssl x509 -req -in root.csr -text -days 3650 -extfile /etc/ssl/openssl.cnf -extensions v3_ca -signkey root.key -out root.crt
openssl req -new -nodes -text -out server.csr -keyout server.key -subj "/CN=$(hostname)"
openssl x509 -req -in server.csr -text -days 365 -CA mycacert.pem -CAkey mycakey.pem -CAcreateserial -out server.crt
# server.crt and server.key should be stored on the server, and root.crt should be stored on the client 
# so the client can verify that the server's leaf certificate was signed by its trusted root certificate. 
# root.key should be stored offline for use in creating future certificates.

# https://www.postgresql.org/docs/current/runtime-config-connection.html#GUC-SSL
sed -i 's/#ssl = off/ssl = on/g' postgresql.conf
sed -i "s/#ssl_ca_file = ''/ssl_ca_file = 'mycacert.pem'/g" postgresql.conf

# sequre connection:
sed -i 's/host all all all scram-sha-256/hostssl all all all scram-sha-256/g' pg_hba.conf
