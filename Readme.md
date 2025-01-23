Стендовый образец кластера [Apache Hadoop](https://hadoop.apache.org), развернутый на [Docker-compose](https://github.com/makrovan/Hadoop-in-Docker/blob/main/docker-compose.yml) и состоящий из:
- [NameNode](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/NameNode/Dockerfile) `/usr/local/hadoop/bin/hdfs namenode`
- [ResourceManager](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/ResourceManager/Dockerfile) `/usr/local/hadoop/bin/yarn" resourcemanager`
- [Map Reduce Job History Server](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/JobHistory/Dockerfile) `/usr/local/hadoop/bin/mapred historyserver`
- [Worker's](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/Worker/Dockerfile) (два)

На Worker-ах запущены DataNode `(sudo -u hdfs /usr/local/hadoop/bin/hdfs datanode)` и NodeManager `(sudo -u yarn /usr/local/hadoop/bin/yarn nodemanager)`.

Кластер развернут в соответствии с [официальной документацией Apache Hadoop](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html) в [безопасном режиме](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html), для разграничения прав доступа поднят сервер [Kerberos](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/KDC/Dockerfile) с настроенным OLDAP-сервером (через TLS). 

Веб-консоли [HDFS](https://hadoop-master.hadoopnet:9871), [YARN](https://hadoop-yarn.hadoopnet:8090), [MapReduce JobHistory server](https://hadoop-history.hadoopnet:19890) доступны по [https](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html#KMS_over_HTTPS_.28SSL.29) после аутентификации [kinit](https://web.mit.edu/kerberos/krb5-1.12/doc/user/user_commands/kinit.html). Для доступа к ним поднят [Hadoop-client](https://), перед запуском которого необходимо запустить X-server, в настройках которого разрешено подключение из клиентсикх сетей, в консоли введена команнда: `xhost + ${localhost}`. В браузере firefox, запущенном на hadoop-client также необходимо настроить SPNEGO: `about:config -> network.negotiate-auth.trusted-uris: hadoopnet -> network.negotiate-auth.trusted-uris -> Accept the Risk and Continue`

Все образы внутри кластера развернуты на Docker-контейнере [makrov/hadoop-image](https://hub.docker.com/r/makrov/hadoop-image) (Ubuntu)

Kerberos-сервер развернут на Docker-контейнере [makrov/hadoop-kdc-server](https://hub.docker.com/r/makrov/hadoop-kdc-server) (Ubuntu):
В соответствии с [официальной документацией Ubuntu](https://ubuntu.com) на сервере развернут [OpenLDAP c TLS-шифрованием](https://ubuntu.com/server/docs/ldap-and-transport-layer-security-tls).

Далее поднят сервер [Kerberos with OpenLDAP backend](#https://ubuntu.com/server/docs/how-to-set-up-kerberos-with-openldap-backend)

Вся остальная конфигурация выполнена внутри [docker-compose.yml](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/docker-compose.yml). Общие конфигурационные файлы в директории [Common](https://github.com/makrovan/Hadoop-in-Docker/tree/792815da32e5fbb38c5fc13c0c509d5451b868c9/Common).
При первом запуске выполняется [форматирование файловой системы HDFS](https://github.com/makrovan/Hadoop-in-Docker/blob/792815da32e5fbb38c5fc13c0c509d5451b868c9/NameNode/init-script.sh). Файловую систему необходимо проинициализировать файлом `tmp/init-fylesystem`. После этого необходимо отдельно запустить `hadoop-history` через `docker start`.
Принципалы hdfs, yarn и mapred создаются в docker-контейнере, пароли задаются вручную. Для сервисов принципалыи keytab-ы создаются каждый раз при загрузке контейнера, передаются через папку `\KDC\keytabs`

https://stackoverflow.com/questions/78692851/could-not-retrieve-mirrorlist-http-mirrorlist-centos-org-release-7arch-x86-6
