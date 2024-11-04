#!/bin/sh -x

# ждем kdc
while [ ! -f /etc/sync/krb5kdc_started ]
do
    sleep 5
    echo "waiting /etc/sync/krb5kdc..."
done

cp /etc/CA/mycacert.pem /usr/local/share/ca-certificates/mycacert.crt
# # cat /usr/local/share/ca-certificates/mycacert.crt >> /etc/ssl/certs/ca-certificates.crt
update-ca-certificates

kinit -k -t /etc/security/keytabs/my.keytab hdfs@DOCKER.NET 

# for solr test
kinit -k -t /etc/security/keytabs/ranger.keytab rangeradmin/hadoop-ranger.docker.net@DOCKER.NET

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
    https://hadoop-solr.docker.net:8983 \
    https://hadoop-ranger.docker.net:6182 \
    https://hadoop-knox.docker.net:8443/gateway/manager/admin-ui/

# sleep infinity&
# wait $!

#xhost +
# network.negotiate-auth.trusted-uris docker.net