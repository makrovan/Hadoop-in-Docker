#!/bin/bash
set -x

# https://knox.apache.org/books/knox-2-1-0/user-guide.html#Using+a+CA+Signed+Key+Pair
su -c '/usr/local/knox/bin/knoxcli.sh create-master --master hadoop' knox
cp /tmp/ssl/keystore.jks /usr/local/knox/data/security/keystores/gateway.jks
keytool -changealias -alias "$(hostname)" -destalias "gateway-identity" -keypass hadoop -keystore /usr/local/knox/data/security/keystores/gateway.jks -storepass hadoop
su -c '/usr/local/knox/bin/knoxcli.sh create-alias hadoop --value hadoop' knox
keytool -keystore /usr/local/knox/data/security/keystores/gateway.jks -storepass hadoop -import -file /etc/CA/mycacert.pem -noprompt
# keytool -v -list -storetype jks -keystore /usr/local/knox/data/security/keystores/gateway.jks -storepass hadoop

# https://knox.apache.org/books/knox-2-1-0/user-guide.html#Secure+Clusters
mkdir -p /etc/knox/conf/
cp /etc/krb5.conf /etc/knox/conf/
cp /usr/local/knox/templates/krb5JAASLogin.conf /etc/knox/conf
sed -i 's/\/etc\/knox\/conf\/knox.service.keytab/\/etc\/security\/keytabs\/knox.service.keytab/' /etc/knox/conf/krb5JAASLogin.conf
sed -i 's/knox@EXAMPLE.COM/knox\/hadoop-knox.hadoopnet@HADOOPNET/' /etc/knox/conf/krb5JAASLogin.conf
xmlstarlet ed --inplace --update "/configuration/property[name='gateway.hadoop.kerberos.secured']/value" --value 'true' /usr/local/knox/conf/gateway-site.xml
xmlstarlet ed --inplace --update "/configuration/property[name='sun.security.krb5.debug']/value" --value 'true' /usr/local/knox/conf/gateway-site.xml

# edit knoxsso for admin-ui (https://hadoop-knox.hadoopnet:8443/gateway/manager/admin-ui/) https://knox.apache.org/books/knox-2-1-0/user-guide.html#Admin+UI
# https://knox.apache.org/books/knox-2-1-0/user-guide.html#Authentication
xmlstarlet ed --inplace --update "/topology/gateway/provider[role='authentication']/param[name='main.ldapRealm.userDnTemplate']/value" --value 'uid={0},ou=users,dc=hadoopnet' /usr/local/knox/conf/topologies/knoxsso.xml
xmlstarlet ed --inplace --update "/topology/gateway/provider[role='authentication']/param[name='main.ldapRealm.contextFactory.url']/value" --value 'ldaps://ldap-server.hadoopnet' /usr/local/knox/conf/topologies/knoxsso.xml
# https://knox.apache.org/books/knox-2-1-0/user-guide.html#LDAP+Configuration
# xmlstarlet ed --inplace --update "/topology/gateway/provider[role='authentication']/param[name='urls./**']/value" --value 'ssl, authcBasic' /usr/local/knox/conf/topologies/knoxsso.xml
# https://knox.apache.org/books/knox-2-1-0/user-guide.html#Hostmap+Provider
xmlstarlet ed --inplace --update "/topology/gateway/provider[role='hostmap']/param[name='localhost']/value" --value 'hadoop-knox.hadoopnet' /usr/local/knox/conf/topologies/knoxsso.xml
# https://knox.apache.org/books/knox-2-1-0/user-guide.html#Hadoop+Group+Lookup+Provider
xmlstarlet ed --inplace --update "/configuration/property[name='gateway.group.config.hadoop.security.group.mapping.ldap.bind.user']/value" --value 'cn=admin,dc=hadoopnet' /usr/local/knox/conf/gateway-site.xml
xmlstarlet ed --inplace --update "/configuration/property[name='gateway.group.config.hadoop.security.group.mapping.ldap.bind.password']/value" --value 'hadoop' /usr/local/knox/conf/gateway-site.xml
xmlstarlet ed --inplace --update "/configuration/property[name='gateway.group.config.hadoop.security.group.mapping.ldap.url']/value" --value 'ldaps://ldap-server.hadoopnet' /usr/local/knox/conf/gateway-site.xml

# https://knox.apache.org/books/knox-2-1-0/user-guide.html#Gateway+Server+Configuration
xmlstarlet ed --inplace --update "/configuration/property[name='gateway.dispatch.whitelist']/value" --value '.*hadoopnet.*;.*localhost.*' /usr/local/knox/conf/gateway-site.xml

xmlstarlet ed --inplace --update "/configuration/property[name='gateway.group.config.hadoop.security.group.mapping.ldap.base']/value" --value 'dc=hadoopnet' /usr/local/knox/conf/gateway-site.xml
xmlstarlet ed --inplace --update "/configuration/property[name='gateway.group.config.hadoop.security.group.mapping.ldap.search.filter.user']/value" --value '(&(objectclass=person)(uid={0}))' /usr/local/knox/conf/gateway-site.xml

# https://knox.apache.org/books/knox-2-1-0/user-guide.html#Logging
xmlstarlet ed --inplace --update "/Configuration/Loggers/Root[@level='ERROR']/@level" --value 'ALL' /usr/local/knox/conf/gateway-log4j2.xml

# https://knox.apache.org/books/knox-2-1-0/user-guide.html#Default+Topology+URLs
xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "default.app.topology.name" -s "//property[last()]" -t elem -n "value" -v "docker-proxy" /usr/local/knox/conf/gateway-site.xml

# https://knox.apache.org/books/knox-2-1-0/user-guide.html#Authorization
# xmlstarlet ed --inplace --update "/topology/gateway/provider[role='authorization']/param[name='knox.acl']/value" --value '*;*;*' /usr/local/knox/conf/topologies/manager.xml

# xmlstarlet ed -L -s "//configuration" -t elem -n "property" -s "//property[last()]" -t elem -n "name" -v "gateway.tls.key.alias" -s "//property[last()]" -t elem -n "value" -v "hadoop" /usr/local/knox/conf/gateway-site.xml

# test knox-proxy:
# apt install -y curl
# curl -i -u ldapuser:pass "https://hadoop-knox.hadoopnet:8443/gateway/docker-proxy/webhdfs/v1/?op=LISTSTATUS"
# curl -i -u ldapuser:pass "https://hadoop-knox.hadoopnet:8443/webhdfs/v1/?op=LISTSTATUS"
# kinit -k -t /etc/security/keytabs/my.keytab hdfs@HADOOPNET
# curl -i --negotiate -L "https://hadoop-master.hadoopnet:9871/webhdfs/v1/?op=LISTSTATUS"
