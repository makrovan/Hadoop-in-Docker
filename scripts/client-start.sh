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

# kinit -k -t /etc/security/keytabs/my.keytab hdfs@HADOOPNET 

# for solr test
kinit -k -t /etc/security/keytabs/ranger.keytab rangeradmin/hadoop-ranger.hadoopnet@HADOOPNET

echo "{
    \"policies\": {
        \"Authentication\": {
            \"SPNEGO\": [\"hadoopnet\"]
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
    https://hadoop-master.hadoopnet:9871 \
    https://hadoop-rmanager.hadoopnet:8090 \
    https://hadoop-history.hadoopnet:19890 \
    https://hadoop-solr.hadoopnet:8983 \
    https://hadoop-ranger.hadoopnet:6182 \
    https://hadoop-knox.hadoopnet:8443/hdfs/index.html \
    https://hadoop-knox.hadoopnet:8443/yarn \
    https://hadoop-knox.hadoopnet:8443/jobhistory \
    https://hadoop-knox.hadoopnet:8443/gateway/manager/admin-ui \
    https://hadoop-knox.hadoopnet:8443/ranger
    # https://hadoop-ranger.hadoopnet:6182/index.html#/policymanager/resource

#xhost +
# network.negotiate-auth.trusted-uris hadoopnet