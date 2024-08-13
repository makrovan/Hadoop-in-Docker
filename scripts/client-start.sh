#!/bin/sh -x

# ждем ldap
while [ `ls /etc/krb5kdc/keyfiles/kdc-ssl | wc -l` -eq 0 ]
do
    sleep 5
    echo "waiting /etc/krb5kdc/keyfiles/kdc-ssl..."
done

cp /etc/krb5kdc/keyfiles/kdc-ssl/mycacert.pem /usr/local/share/ca-certificates/mycacert.crt
# # cat /usr/local/share/ca-certificates/mycacert.crt >> /etc/ssl/certs/ca-certificates.crt
update-ca-certificates

# ждем kdc
kinit -k -t /etc/security/keytab/my.keytab hdfs@DOCKER.NET 
while [ $? -ne 0 ]
do
    sleep 5
    echo "waiting kinit..."
    kinit -k -t /etc/security/keytab/my.keytab hdfs@DOCKER.NET 
done

echo "{
    \"policies\": {
        \"Authentication\": {
            \"SPNEGO\": [\"docker.net\"]
        },
        \"Certificates\": {
            \"ImportEnterpriseRoots\": true
        },
         \"SecurityDevices\": {
            \"p11-kit-trust\": \"/usr/lib/pkcs11/p11-kit-trust.so\"
        }
    }
}" >> /usr/lib/firefox/distribution/policies.json
            # \"Install\": [ \"/root/.mozilla/certificates/mycacert.pem\" ]

firefox about:policies \
    https://hadoop-master.docker.net:9871 \
    https://hadoop-rmanager.docker.net:8090 \
    https://hadoop-history.docker.net:19890 \
    http://hadoop-solr.docker.net:6083 \
    http://hadoop-ranger.docker.net:6080

# sleep infinity&
# wait $!

#xhost +
# network.negotiate-auth.trusted-uris docker.net