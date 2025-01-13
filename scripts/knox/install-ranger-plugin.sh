#!/bin/bash
set -x

# https://cwiki.apache.org/confluence/display/RANGER/Ranger+Installation+Guide#RangerInstallationGuide-Install/ConfigureRangerKnoxPlugin
echo "Installing ranger-knox...."
cd /usr/local
tar zxf ranger-2.5.1-SNAPSHOT-knox-plugin.tar.gz
ln -s ranger-2.5.1-SNAPSHOT-knox-plugin ranger-knox-plugin
cd ranger-knox-plugin

cp -f /tmp/knox/install.properties .
./enable-knox-plugin.sh

apt install -y xmlstarlet
# https://lists.apache.org/thread/h04mw6j9rs4wclt5scsqfv27h5jj27sf
# https://cwiki.apache.org/confluence/display/RANGER/NiFi+Plugin#NiFiPlugin-CreateNiFiRangerpluginAuditconfigfile# https://docs.cloudera.com/csm-operator/1.2/kafka-security/topics/csm-op-authz-ranger.html
# https://solr.apache.org/guide/8_4/kerberos-authentication-plugin.html#define-a-jaas-configuration-file
# add principal to /usr/local/hadoop/etc/hadoop/ranger-hdfs-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.destination.solr.force.use.inmemory.jaas.config" -s "//property[last()]" -t elem -n "value" -v "true" /usr/local/knox/conf/ranger-knox-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.loginModuleControlFlag" -s "//property[last()]" -t elem -n "value" -v "required" /usr/local/knox/conf/ranger-knox-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.loginModuleName" -s "//property[last()]" -t elem -n "value" -v "com.sun.security.auth.module.Krb5LoginModule" /usr/local/knox/conf/ranger-knox-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.keyTab" -s "//property[last()]" -t elem -n "value" -v "/etc/security/keytabs/ranger.keytab" /usr/local/knox/conf/ranger-knox-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.principal" -s "//property[last()]" -t elem -n "value" -v "rangeradmin/hadoop-ranger.docker.net@DOCKER.NET" /usr/local/knox/conf/ranger-knox-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.serviceName" -s "//property[last()]" -t elem -n "value" -v "solr" /usr/local/knox/conf/ranger-knox-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.storeKey" -s "//property[last()]" -t elem -n "value" -v "false" /usr/local/knox/conf/ranger-knox-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.useKeyTab" -s "//property[last()]" -t elem -n "value" -v "true" /usr/local/knox/conf/ranger-knox-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.debug" -s "//property[last()]" -t elem -n "value" -v "true" /usr/local/knox/conf/ranger-knox-audit.xml

mkdir -p /var/log/knox/audit/solr/spool
chown -R knox:knox /var/log/knox/audit/solr/spool
chown -R knox:knox /etc/ranger/knoxdev/