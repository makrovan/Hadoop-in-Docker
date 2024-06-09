Стендовый образец кластера [Apache Hadoop](https://hadoop.apache.org), развернутый на [Docker-compose](https://github.com/makrovan/Hadoop-in-Docker/blob/main/docker-compose.yml) и состоящий из:
- [NameNode](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/NameNode/Dockerfile) `/usr/local/hadoop/bin/hdfs namenode`
- [ResourceManager](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/ResourceManager/Dockerfile) `/usr/local/hadoop/bin/yarn" resourcemanager`
- [Map Reduce Job History Server](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/JobHistory/Dockerfile) `/usr/local/hadoop/bin/mapred historyserver`
- [Worker's](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/Worker/Dockerfile) (два)

На Worker-ах запущены DataNode `(sudo -u hdfs /usr/local/hadoop/bin/hdfs datanode)` и NodeManager `(sudo -u yarn /usr/local/hadoop/bin/yarn nodemanager)`.

Кластер развернут в соответствии с [официальной документацией Apache Hadoop](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html) в [безопасном режиме](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html), для разграничения прав доступа поднят сервер [Kerberos](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/KDC/Dockerfile). 

Веб-консоли [HDFS](https://hadoop-master.docker.net:9871), [YARN](https://hadoop-yarn.docker.net:8090), [MapReduce JobHistory server](https://hadoop-history.docker.net:19890) доступны по [https](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html#KMS_over_HTTPS_.28SSL.29) после аутентификации [kinit](https://web.mit.edu/kerberos/krb5-1.12/doc/user/user_commands/kinit.html). Для доступа к ним поднят [Hadoop-client](https://), перед запуском которого необходимо запустить X-server, в настройках которого разрешено подключение из клиентсикх сетей, в консоли введена команнда: `xhost + ${localhost}`. В браузере firefox, запущенном на hadoop-client также необходимо настроить SPNEGO: `about:config -> network.negotiate-auth.trusted-uris: docker.net -> network.negotiate-auth.trusted-uris -> Accept the Risk and Continue`

Все образы внутри кластера развернуты на Docker-контейнере [makrov/hadoop-image](https://hub.docker.com/r/makrov/hadoop-image) (Ubuntu):
- `apt-get update`
- `apt-get install openjdk-8-jdk wget krb5-user -y` (Default Kerberos version 5 realm: DOCKER.NET, Kerberos servers for your realm: kdc-server.docker.net, Administrative server for your Kerberos realm: kdc-server.docker.net)
- `cd /usr/local`
- `wget https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.4.0-aarch64.tar.gz`
- `tar xzf hadoop-3.4.0-aarch64.tar.gz`
- `mv hadoop-3.4.0 hadoop`
- `rm hadoop-3.4.0-aarch64.tar.gz`
- `addgroup hadoop`
- `adduser --ingroup hadoop hdfs (password: hadoop)`
- `adduser --ingroup hadoop yarn (password: hadoop)`
- `adduser --ingroup hadoop mapred (password: hadoop)`
- `su hdfs`
- `cd ~`
- `keytool -genkey -alias jetty -keyalg RSA (Enter keystore password: hadoop, What is your first and last name? hadoop-master.docker.net, Enter key password for <jetty>: same as keystore password)`
- `exit`
- `mkdir -p -m 700 /usr/local/hadoop/data/nameNode`
- `mkdir -p -m 700 /usr/local/hadoop/data/dataNade`
- `mkdir -p -m 775 /usr/local/hadoop/logs`
- `mkdir -p -m 755 /tmp/hadoop-yarn/nm-local-dir`
- `mkdir -p -m 755 /usr/local/hadoop/logs/userlogs`
- `chown hdfs:hadoop -R /usr/local/hadoop/data/nameNode`
- `chown hdfs:hadoop -R /usr/local/hadoop/data/dataNade`
- `chown hdfs:hadoop -R /usr/local/hadoop/logs`
- `chown yarn:hadoop -R /tmp/hadoop-yarn/nm-local-dir`
- `chown yarn:hadoop -R /usr/local/hadoop/logs/userlogs`

Kerberos-сервер развернут на Docker-контейнере [makrov/hadoop-kdc-server](https://hub.docker.com/r/makrov/hadoop-kdc-server) (Ubuntu):
В соответствии с [официальной документацией Ubuntu](https://ubuntu.com) на сервере развернут [OpenLDAP c TLS-шифрованием](https://ubuntu.com/server/docs/ldap-and-transport-layer-security-tls):
- `apt update`
- `apt install slapd ldap-utils gnutls-bin ssl-cert ca-certificates -y` (Administrator password: hadoop)
- `certtool --generate-privkey --bits 4096 --outfile /etc/ssl/private/mycakey.pem`<br />
 `echo "cn = Example Company`<br />
 &emsp;`ca`<br />
 &emsp;`cert_signing_key`<br />
 &emsp;`expiration_days = 3650" >> /etc/ssl/ca.info`
- `certtool --generate-self-signed --load-privkey /etc/ssl/private/mycakey.pem --template /etc/ssl/ca.info --outfile /usr/local/share/ca-certificates/mycacert.crt`
- `update-ca-certificates`
- `certtool --generate-privkey --bits 2048 --outfile /etc/ldap/ldap01_slapd_key.pem`
- `echo "organization = Example Company`<br />
 &emsp;`cn = kdc-server.docker.net`<br />
 &emsp;`tls_www_server`<br />
 &emsp;`encryption_key`<br />
 &emsp;`signing_key`<br />
 &emsp;`expiration_days = 365" >> /etc/ssl/ldap01.info`
- `certtool --generate-certificate --load-privkey /etc/ldap/ldap01_slapd_key.pem --load-ca-certificate /etc/ssl/certs/mycacert.pem --load-ca-privkey /etc/ssl/private/mycakey.pem --template /etc/ssl/ldap01.info --outfile /etc/ldap/ldap01_slapd_cert.pem`
- `echo "dn: cn=config`<br />
 &emsp;`add: olcTLSCACertificateFile`<br />
 &emsp;`olcTLSCACertificateFile: /etc/ssl/certs/mycacert.pem`<br />
 &emsp;`-`<br />
 &emsp;`add: olcTLSCertificateFile`<br />
 &emsp;`olcTLSCertificateFile: /etc/ldap/ldap01_slapd_cert.pem`<br />
 &emsp;`-`<br />
 &emsp;`add: olcTLSCertificateKeyFile`<br />
 &emsp;`olcTLSCertificateKeyFile: /etc/ldap/ldap01_slapd_key.pem" >> certinfo.ldif`
- `slapd -h "ldap:// ldapi://"`
- `ldapmodify -Y EXTERNAL -H ldapi:/// -f certinfo.ldif`
- `pkill -f slapd`
- `slapd -h "ldap:// ldapi:// ldaps://"`<br />
Для проверки используем: `ldapwhoami -x -ZZ -H ldap://kdc-server.docker.net` и `ldapwhoami -x -H ldaps://kdc-server.docker.net`<br />
Далее поднят сервер [Kerberos with OpenLDAP backend](#https://ubuntu.com/server/docs/how-to-set-up-kerberos-with-openldap-backend)
- `apt install krb5-kdc-ldap krb5-admin-server schema2ldif nano -y` (Default Kerberos version 5 realm: DOCKER.NET, Kerberos servers for your realm: kdc-server.docker.net, Administrative server for your Kerberos realm: kdc-server.docker.net)
- `nano /etc/ldap/schema/kerberos.schema` (Добавляем код из файла [kerberos.schema](https://github.com/makrovan))
- `ldap-schema-manager -i kerberos.schema` (Для проверки используем: `ldapsearch -QLLLY EXTERNAL -H ldapi:/// -b cn=schema,cn=config dn | grep -i kerberos` и `ldapsearch -QLLLY EXTERNAL -H ldapi:/// -b cn={4}kerberos,cn=schema,cn=config | grep NAME | cut -d' ' -f5 | sort`)
- `ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF`<br />
 &emsp;`dn: olcDatabase={1}mdb,cn=config`<br />
 &emsp;`add: olcDbIndex`<br />
 &emsp;`olcDbIndex: krbPrincipalName eq,pres,sub`<br />
 &emsp;`EOF`
- `ldapadd -x -D cn=admin,dc=docker,dc=net -W <<EOF`<br />
 &emsp;`dn: uid=kdc-service,dc=docker,dc=net`<br />
 &emsp;`uid: kdc-service`<br />
 &emsp;`objectClass: account`<br />
 &emsp;`objectClass: simpleSecurityObject`<br />
 &emsp;`userPassword: {CRYPT}x`<br />
 &emsp;`description: Account used for the Kerberos KDC`<br /><br />
 &emsp;`dn: uid=kadmin-service,dc=docker,dc=net`<br />
 &emsp;`uid: kadmin-service`<br />
 &emsp;`objectClass: account`<br />
 &emsp;`objectClass: simpleSecurityObject`<br />
 &emsp;`userPassword: {CRYPT}x`<br />
 &emsp;`description: Account used for the Kerberos Admin server`<br />
 &emsp;`EOF`
(Enter LDAP Password: hadoop)
- `ldappasswd -x -D cn=admin,dc=docker,dc=net -W -S uid=kdc-service,dc=docker,dc=net` (New password: hadoop; Enter LDAP Password: hadoop) Для проверки: `ldapwhoami -x -D uid=kdc-service,dc=docker,dc=net -W` (Enter LDAP Password: hadoop)
- `ldappasswd -x -D cn=admin,dc=docker,dc=net -W -S uid=kadmin-service,dc=docker,dc=net` (New password: hadoop; Enter LDAP Password: hadoop) Для проверки: `ldapwhoami -x -D uid=kadmin-service,dc=docker,dc=net -W` (Enter LDAP Password: hadoop)
- `ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF`<br />
 &emsp;`dn: olcDatabase={1}mdb,cn=config`<br />
 &emsp;`add: olcAccess`<br />
 &emsp;`olcAccess: {2}to attrs=krbPrincipalKey`<br />
 &emsp;`  by anonymous auth`<br />
 &emsp;`  by dn.exact="uid=kdc-service,dc=docker,dc=net" read`<br />
 &emsp;`  by dn.exact="uid=kadmin-service,dc=docker,dc=net" write`<br />
 &emsp;`  by self write`<br />
 &emsp;`  by * none`<br /><br />
 &emsp;`add: olcAccess`<br />
 &emsp;`olcAccess: {3}to dn.subtree="cn=krbContainer,dc=docker,dc=net"`<br />
 &emsp;`  by dn.exact="uid=kdc-service,dc=docker,dc=net" read`<br />
 &emsp;`  by dn.exact="uid=kadmin-service,dc=docker,dc=net" write`<br />
 &emsp;`  by * none`<br />
 `EOF`<br />
Для проверки: `slapcat -b cn=config`
- `nano /etc/krb5.conf` Здесь добавляем код:<br />
*[realms]*<br />
&emsp;*docker.net =* {<br />
&emsp;&emsp;*kdc = kdc-server.docker.net*<br />
&emsp;&emsp;*admin_server = kdc-server.docker.net*<br />
&emsp;&emsp;*default_domain = docker.net*<br />
&emsp;&emsp;*database_module = openldap_ldapconf*<br />
&emsp;*}*<br /><br />
*[dbdefaults]*<br />
&emsp;*ldap_kerberos_container_dn = cn=krbContainer,dc=docker,dc=net*<br />
*[dbmodules]*<br />
&emsp;*openldap_ldapconf = {*<br />
&emsp;&emsp;*db_library = kldap*<br /><br />
&emsp;&emsp;*# if either of these is false, then the ldap_kdc_dn needs to*<br />
&emsp;&emsp;*# have write access*<br />
&emsp;&emsp;*disable_last_success = true*<br />
&emsp;&emsp;*disable_lockout  = true*<br /><br />
&emsp;&emsp;*# this object needs to have read rights on*<br />
&emsp;&emsp;*# the realm container, principal container and realm sub-trees*<br />
&emsp;&emsp;*ldap_kdc_dn = "uid=kdc-service,dc=docker,dc=net"*<br /><br />
&emsp;&emsp;*# this object needs to have read and write rights on*<br />
&emsp;&emsp;*# the realm container, principal container and realm sub-trees*<br />
&emsp;&emsp;*ldap_kadmind_dn = "uid=kadmin-service,dc=docker,dc=net"*<br /><br /><br />
&emsp;&emsp;*ldap_service_password_file = /etc/krb5kdc/service.keyfile*<br />
&emsp;&emsp;*ldap_servers = ldapi:///*<br />
&emsp;&emsp;*ldap_conns_per_server = 5*<br />
&emsp;*}*<br />

- `kdb5_ldap_util -D cn=admin,dc=docker,dc=net create -subtrees dc=docker,dc=net -r DOCKER.NET -s -H ldapi:///` (Password for "cn=admin,dc=docker,dc=net": hadoop; Enter KDC database master key: hadoop)
- `kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kdc-service,dc=docker,dc=net` (Password for "cn=admin,dc=docker,dc=net": hadoop; Password for "uid=kdc-service,dc=docker,dc=net": hadoop)
- `kdb5_ldap_util -D cn=admin,dc=docker,dc=net stashsrvpw -f /etc/krb5kdc/service.keyfile uid=kadmin-service,dc=docker,dc=net` (Password for "cn=admin,dc=docker,dc=net": hadoop; Password for "uid=kdc-service,dc=docker,dc=net": hadoop)
- `echo "*/admin@EXAMPLE.COM    *" >> /etc/krb5kdc/kadm5.acl`
- `krb5kdc`
- `kadmind`
- `kadmin.local -q 'addprinc hdfs'` (Enter password for principal "hdfs@DOCKER.NET": hadoop)
- `kadmin.local -q 'addprinc yarn'` (Enter password for principal "yarn@DOCKER.NET": hadoop)
- `kadmin.local -q 'addprinc mapred'` (Enter password for principal "mapred@DOCKER.NET": hadoop)
- `ktutil`
 &emsp;`addent -password -p hdfs@DOCKER.NET -k 0 -e aes256-cts` (Password for hdfs@DOCKER.NET: hadoop)<br />
 &emsp;`addent -password -p yarn@DOCKER.NET -k 1 -e aes256-cts` (Password for yarn@DOCKER.NET: hadoop)<br />
 &emsp;`addent -password -p mapred@DOCKER.NET -k 2 -e aes256-cts` (Password for mapred@DOCKER.NET: hadoop)<br />
 &emsp;`wkt /etc/krb5kdc/my.keytab`<br />
 &emsp;`q`<br />
Вся остальная конфигурация выполнена внутри [docker-compose.yml](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/docker-compose.yml). Общие конфигурационные файлы в директории [Common](https://github.com/makrovan/Hadoop-in-Docker/tree/792815da32e5fbb38c5fc13c0c509d5451b868c9/Common).
При первом запуске выполняется [форматирование файловой системы HDFS](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/NameNode/init-script.sh). Файловую систему необходимо проинициализировать файлом `tmp/init-fylesystem`. После этого необходимо отдельно запустить hadoop-history через `docker start`.
Принципалы hdfs, yarn и mapred создаются в docker-контейнере, пароли задаются вручную. Для сервисов принципалыи keytab-ы создаются каждый раз при загрузке контейнера, передаются через папку `\KDC\keytabs`