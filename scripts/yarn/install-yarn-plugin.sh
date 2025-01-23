#!/bin/bash
set -x

# https://cwiki.apache.org/confluence/display/RANGER/Ranger+installation+in+Kerberized++Environment#RangerinstallationinKerberizedEnvironment-Installing/EnablingRangerYARNplugin
echo "Installing ranger-yarn...."
cd /usr/local
tar zxf ranger-2.5.1-SNAPSHOT-yarn-plugin.tar.gz
ln -s ranger-2.5.1-SNAPSHOT-yarn-plugin ranger-yarn
cd ranger-yarn
cp -f /tmp/yarn/install.properties .
./enable-yarn-plugin.sh

apt install -y xmlstarlet
# https://lists.apache.org/thread/h04mw6j9rs4wclt5scsqfv27h5jj27sf
# https://cwiki.apache.org/confluence/display/RANGER/NiFi+Plugin#NiFiPlugin-CreateNiFiRangerpluginAuditconfigfile# https://docs.cloudera.com/csm-operator/1.2/kafka-security/topics/csm-op-authz-ranger.html
# https://solr.apache.org/guide/8_4/kerberos-authentication-plugin.html#define-a-jaas-configuration-file
# add principal to /usr/local/hadoop/etc/hadoop/ranger-hdfs-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.destination.solr.force.use.inmemory.jaas.config" -s "//property[last()]" -t elem -n "value" -v "true" /usr/local/hadoop/etc/hadoop/ranger-yarn-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.loginModuleControlFlag" -s "//property[last()]" -t elem -n "value" -v "required" /usr/local/hadoop/etc/hadoop/ranger-yarn-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.loginModuleName" -s "//property[last()]" -t elem -n "value" -v "com.sun.security.auth.module.Krb5LoginModule" /usr/local/hadoop/etc/hadoop/ranger-yarn-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.keyTab" -s "//property[last()]" -t elem -n "value" -v "/etc/security/keytabs/ranger.keytab" /usr/local/hadoop/etc/hadoop/ranger-yarn-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.principal" -s "//property[last()]" -t elem -n "value" -v "rangeradmin/hadoop-ranger.hadoopnet@HADOOPNET" /usr/local/hadoop/etc/hadoop/ranger-yarn-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.serviceName" -s "//property[last()]" -t elem -n "value" -v "solr" /usr/local/hadoop/etc/hadoop/ranger-yarn-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.storeKey" -s "//property[last()]" -t elem -n "value" -v "false" /usr/local/hadoop/etc/hadoop/ranger-yarn-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.useKeyTab" -s "//property[last()]" -t elem -n "value" -v "true" /usr/local/hadoop/etc/hadoop/ranger-yarn-audit.xml
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "xasecure.audit.jaas.Client.option.debug" -s "//property[last()]" -t elem -n "value" -v "true" /usr/local/hadoop/etc/hadoop/ranger-yarn-audit.xml

mkdir -p /var/log/hadoop/yarn/audit/solr/spool
chown -R yarn:hadoop /var/log/hadoop/yarn/audit/solr/spool
chown -R yarn:hadoop /etc/ranger/yarndev/