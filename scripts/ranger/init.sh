#!/bin/bash
set -x

apt install -y xmlstarlet

mkdir /root/.postgresql
cp /etc/CA/mycacert.pem /root/.postgresql/root.crt

# mkdir -p /tmp/ssl/client
# cd /tmp/ssl/client

# openssl req -new -nodes -text -out root.csr -keyout root.key -subj "/CN=$(hostname)"
# openssl x509 -req -in root.csr -text -days 3650 -extfile /etc/ssl/openssl.cnf -extensions v3_ca -signkey root.key -out root.crt
# keytool -import -alias $(hostname) -file root.crt -keystore root.jks -keypass hadoop -storepass hadoop -noprompt

# openssl req -new -noenc -text -out pg_client.csr -keyout pg_client.key -subj "/CN=$(hostname)"
# openssl x509 -req -in pg_client.csr -text -days 365 -CA root.crt -CAkey root.key -CAcreateserial -out pg_client.crt
# openssl pkcs12 -export -in pg_client.crt -inkey pg_client.key -out pg_client.p12 -name postgres -password pass:hadoop
# keytool -importkeystore -destkeystore pg_client.jks -srckeystore pg_client.p12 -srcstoretype pkcs12 -srcstorepass hadoop -deststorepass hadoop

# # mkdir -p /tmp/ssl/CA/
# # cp /etc/CA/mycacert.jks /tmp/ssl/CA/mycacert.jks
# # keytool -import -alias $(hostname) -file /etc/CA/mycacert.pem -keystore /tmp/ssl/mycacert.jks -keypass hadoop -storepass hadoop -noprompt
# openssl x509 -in /etc/CA/mycacert.pem -out /tmp/ssl/mycacert.crt.der -outform der
# keytool -import -file /tmp/ssl/mycacert.crt.der -keystore /tmp/ssl/mycacert.jks -storepass hadoop -noprompt

echo "Installing ranger-admin...."
# https://cwiki.apache.org/confluence/display/RANGER/Ranger+Installation+Guide#RangerInstallationGuide-Install/ConfigureRangerAdmin
cd /usr/local
tar zxf ranger-2.5.1-SNAPSHOT-admin.tar.gz
ln -s ranger-2.5.1-SNAPSHOT-admin ranger-admin
cd ranger-admin
cp -f /tmp/admin/install.properties .
./setup.sh
./set_globals.sh

# chown -R ranger:ranger /tmp/ssl/*
# chmod 666 /tmp/ssl/*
# chown ranger:ranger /etc/ranger/conf/ranger-audit-solr-ssl.xml

# enable kerberos in ranger-admin
# xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/core-site.xml
# sed -i 's/<property\/>/<property><name>hadoop.security.authentication<\/name><value>kerberos<\/value><\/property>/' /etc/ranger/admin/conf/core-site.xml
# # hadoop.security.auth_to_local in core-site.xml не работает kerberos principal преобразуется в имя пользователя путем отброса всего после "/": rangerusersync/hadoop-ranger.docker.net@DOCKER.NET -> rangerusersync
# xmlstarlet ed -L /etc/ranger/admin/conf/core-site.xml


# https://o.onslip.net/HDPDocuments/HDP3/HDP-2.5.1/security-reference/content/configuring_non_ambari_ranger_ssl_using_public_ca_certificates_configuring_ranger_admin.html
xmlstarlet ed --inplace --update "/configuration/property[name='ranger.service.http.port']/value" --value '' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace --update "/configuration/property[name='ranger.service.https.attrib.keystore.pass']/value" --value 'hadoop' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>ranger.service.https.attrib.clientAuth<\/name><value>want<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>ranger.service.https.attrib.client.auth<\/name><value>want<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>ranger.https.attrib.keystore.file<\/name><value>\/tmp\/ssl\/keystore.jks<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml

# set password for DB connection (may be 'cert' connection later...):
xmlstarlet edit --inplace --update "/configuration/property[name='ranger.jpa.jdbc.password']/value" --value "hadoop" /etc/ranger/admin/conf/ranger-admin-site.xml

# set password for https:// connection to SOLR (wihout it doesn't work)
# https://solr.apache.org/guide/solr/latest/deployment-guide/enabling-ssl.html#index-a-document-using-cloudsolrclient
xmlstarlet edit --inplace --update "/configuration/property[name='ranger.keystore.password']/value" --value "hadoop" /etc/ranger/admin/conf/ranger-admin-default-site.xml
xmlstarlet edit --inplace --update "/configuration/property[name='ranger.truststore.password']/value" --value "hadoop" /etc/ranger/admin/conf/ranger-admin-default-site.xml

# log level setting
xmlstarlet edit --inplace --update "/configuration/root[@level='warn']/@level" --value "trace" /etc/ranger/admin/conf/logback.xml
# sed -i 's/root level=\"warn\"/root level=\"trace\"/g' /etc/ranger/admin/conf/logback.xml

# solr kerberos authentification
# https://github.com/apache/ranger/blob/ranger-2.5/security-admin/src/main/java/org/apache/ranger/solr/SolrMgr.java#L151
# https://lists.apache.org/thread/o77dy16tz6wo1h39zm7yg3dyn88d6l0v
# https://github.com/apache/ranger/blob/ranger-1.2/agents-audit/src/main/java/org/apache/ranger/audit/utils/InMemoryJAASConfiguration.java#L44
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>xasecure.audit.jaas.Client.loginModuleName<\/name><value>com.sun.security.auth.module.Krb5LoginModule<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>xasecure.audit.jaas.Client.loginModuleControlFlag<\/name><value>required<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>xasecure.audit.jaas.Client.option.useKeyTab<\/name><value>true<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>xasecure.audit.jaas.Client.option.storeKey<\/name><value>true<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>xasecure.audit.jaas.Client.option.serviceName<\/name><value>rangeradmin<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>xasecure.audit.jaas.Client.option.keyTab<\/name><value>\/etc\/security\/keytabs\/ranger.keytab<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>xasecure.audit.jaas.Client.option.principal<\/name><value>rangeradmin\/hadoop-ranger.docker.net@DOCKER.NET<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/admin/conf/ranger-admin-site.xml
sed -i 's/<property\/>/<property><name>xasecure.audit.jaas.Client.option.debug<\/name><value>true<\/value><\/property>/' /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace --delete "/configuration/property[name='ranger.solr.audit.user']" /etc/ranger/admin/conf/ranger-admin-site.xml
xmlstarlet ed --inplace --delete "/configuration/property[name='ranger.solr.audit.user.password']" /etc/ranger/admin/conf/ranger-admin-site.xml

# KNOX_PK=$(cat /etc/kpk/knox_pubkey)
xmlstarlet edit --inplace --update "/configuration/property[name='ranger.sso.publicKey']/value" --value $(cat /etc/kpk/knox_pubkey) /etc/ranger/admin/conf/ranger-admin-site.xml

xmlstarlet ed -L /etc/ranger/admin/conf/ranger-admin-site.xml

ranger-admin start

# https://issues.apache.org/jira/browse/RANGER-4800
echo "Installing ranger-usersync...."
cd /usr/local
tar zxf ranger-2.5.1-SNAPSHOT-usersync.tar.gz
ln -s ranger-2.5.1-SNAPSHOT-usersync ranger-usersync
cd ranger-usersync
mkdir -p /var/log/ranger-usersync
chown ranger:ranger /var/log/ranger-usersync
cp -f /tmp/usersync/install.properties .
# https://issues.apache.org/jira/browse/SVN-4899
sed -i 's/readfp/read_file/g' setup.py
./setup.sh

# # sed -i 's/root level=\"info\"/root level=\"trace\"/g' /etc/ranger/usersync/conf/logback.xml
xmlstarlet edit --inplace --update "/configuration/root[@level='info']/@level" --value "trace" /etc/ranger/usersync/conf/logback.xml
xmlstarlet edit --inplace --update "/configuration/property[name='ranger.usersync.enabled']/value" --value "true" /etc/ranger/usersync/conf/ranger-ugsync-site.xml

# enable kerberos in ranger-usersync
# xmlstarlet ed --inplace -s /configuration -t elem -n property /etc/ranger/usersync/conf/core-site.xml
# sed -i 's/<property\/>/<property><name>hadoop.security.authentication<\/name><value>kerberos<\/value><\/property>/' /etc/ranger/usersync/conf/core-site.xml
# xmlstarlet ed -L /etc/ranger/usersync/conf/core-site.xml

ranger-usersync start

# admin Ranger123