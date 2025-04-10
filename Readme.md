Стендовый образец кластера [Apache Hadoop](https://hadoop.apache.org), развернутый на [Docker-compose](https://github.com/makrovan/Hadoop-in-Docker/blob/main/docker-compose.yml) и состоящий из:
- NameNode `/usr/local/hadoop/bin/hdfs namenode`
- ResourceManager `/usr/local/hadoop/bin/yarn" resourcemanager`
- Map Reduce Job History Server `/usr/local/hadoop/bin/mapred historyserver`
- Worker's

На Worker-ах запущены DataNode `(sudo -u hdfs /usr/local/hadoop/bin/hdfs datanode)` и NodeManager `(sudo -u yarn /usr/local/hadoop/bin/yarn nodemanager)`.

Кластер развернут в соответствии с [официальной документацией Apache Hadoop](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html) в [безопасном режиме](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html), для разграничения прав доступа поднят сервер Kerberos с настроенным OLDAP-сервером (через TLS).

В настоящее время наиболее полное описание данного проекта [тут](https://habr.com/ru/articles/885646/).
