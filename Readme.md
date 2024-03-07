Стендовый образец кластера [Apache Hadoop](https://hadoop.apache.org), развернутый на [Docker-compose](https://github.com/makrovan/Hadoop-in-Docker/blob/main/docker-compose.yml) и состоящий из:
- [NameNode](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/NameNode/Dockerfile) `/usr/local/hadoop/bin/hdfs namenode`
- [ResourceManager](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/ResourceManager/Dockerfile) `/usr/local/hadoop/bin/yarn" resourcemanager`
- [WebAppProxy](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/WebProxy/Dockerfile) `/usr/local/hadoop/bin/yarn proxyserver`
- [Map Reduce Job History Server](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/JobHistory/Dockerfile) `/usr/local/hadoop/bin/mapred historyserver`
- [Worker's](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/Worker/Dockerfile) (два)

На Worker-ах запущены DataNode `(sudo -u hdfs /usr/local/hadoop/bin/hdfs datanode)` и NodeManager `(sudo -u yarn /usr/local/hadoop/bin/yarn nodemanager)`.

Кластер развернут в соответствии с официальной [документацией Apache Hadoop](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html) в [безопасном режиме](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html), для разграничения прав доступа поднят сервер [Kerberos](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/KDC/Dockerfile). Веб-консоли [HDFS](https://localhost:9871/), [YARN](https://localhost:8090/), [MapReduce JobHistory server](https://localhost:19890/) доступны по [https](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html#KMS_over_HTTPS_.28SSL.29) после аутентификации [kinit](https://web.mit.edu/kerberos/krb5-1.12/doc/user/user_commands/kinit.html).

Все образы внутри кластера развернуты на Docker-контейнере [makrov/hadoop-image](https://hub.docker.com/r/makrov/hadoop-image) (Ubuntu):
- `apt-get update`
- `apt-get install openjdk-8-jdk wget krb5-user -y` (Default Kerberos version 5 realm: REALM.TLD, Kerberos servers for your realm: kdc-server, Administrative server for your Kerberos realm: kdc-server)
- `cd /usr/local`
- `wget https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.3.6-aarch64.tar.gz`
- `tar xzf hadoop-3.3.6-aarch64.tar.gz`
- `mv hadoop-3.3.6 hadoop`
- `rm hadoop-3.3.6-aarch64.tar.gz`
- `addgroup hadoop`
- `adduser --ingroup hadoop hdfs (password: hadoop)`
- `adduser --ingroup hadoop yarn (password: hadoop)`
- `adduser --ingroup hadoop mapred (password: hadoop)`
- `su hdfs`
- `cd ~`
- `keytool -genkey -alias jetty -keyalg RSA (Enter keystore password: Hadoop, What is your first and last name? hadoop-master)`
- `exit`
- `chown hdfs:hadoop -R /usr/local/hadoop/`
- `chmod g+rwx -R /usr/local/hadoop/`

Kerberos-сервер развернут на Docker-контейнере [makrov/hadoop-kdc-server](https://hub.docker.com/r/makrov/hadoop-kdc-server) (Ubuntu):
- `apt-get update`
- `apt install krb5-kdc krb5-admin-server -y` (Default Kerberos version 5 realm: REALM.TLD, Kerberos servers for your realm: kdc-server, Administrative server for your Kerberos realm: kdc-server)
- `krb5_newrealm` (Enter KDC database master key: hadoop)
- `kadmin.local -q 'addprinc admin/admin'` (Enter password for principal "admin/admin@REALM.TLD": hadoop)
- `echo "*/admin@REALM.TLD *" >> /etc/krb5kdc/kadm5.acl`

Вся остальная конфигурация выполнена внутри [docker-compose.yml](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/docker-compose.yml). Общие конфигурационные файлы в директории [Common](https://github.com/makrovan/Hadoop-in-Docker/tree/792815da32e5fbb38c5fc13c0c509d5451b868c9/Common).
При первом запуске выполняется [форматирование файловой системы HDFS](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/NameNode/init-script.sh), запуск сервера MapReduce JobHistory "падает", из-за отсутствия прав доступа... 

При использовании [форматирование файловой системы HDFS](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/NameNode/init-script.sh) в последующем отключить, настроить необходимые права доступа.
