# Hadoop-image с общей конфигурацией утилитами
FROM ubuntu AS hadoop-image
ARG DEBIAN_FRONTEND=noninteractive
# https://stackoverflow.com/questions/24991136/docker-build-could-not-resolve-archive-ubuntu-com-apt-get-fails-to-install-a
RUN apt update
RUN apt install -y openjdk-8-jdk 
RUN apt install -y krb5-user 
RUN apt install -y ca-certificates
WORKDIR /tmp
ADD https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz /tmp/
RUN tar xzf hadoop-3.4.0.tar.gz -C /usr/local
RUN rm hadoop-3.4.0.tar.gz
RUN mv /usr/local/hadoop-3.4.0 /usr/local/hadoop
RUN addgroup hadoop
RUN adduser --ingroup hadoop --disabled-password --gecos "" hdfs
RUN adduser --ingroup hadoop --disabled-password --gecos "" yarn
RUN adduser --ingroup hadoop --disabled-password --gecos "" mapred
RUN mkdir -p -m 700 /usr/local/hadoop/data/nameNode
RUN mkdir -p -m 700 /usr/local/hadoop/data/dataNode
RUN mkdir -p -m 775 /usr/local/hadoop/logs
RUN mkdir -p -m 755 /tmp/hadoop-yarn/nm-local-dir
RUN mkdir -p -m 755 /usr/local/hadoop/logs/userlogs
RUN chown hdfs:hadoop -R /usr/local/hadoop/data/nameNode
RUN chown hdfs:hadoop -R /usr/local/hadoop/data/dataNode
RUN chown hdfs:hadoop -R /usr/local/hadoop/logs
RUN chown yarn:hadoop -R /tmp/hadoop-yarn/nm-local-dir
RUN chown yarn:hadoop -R /usr/local/hadoop/logs/userlogs
RUN useradd -g hadoop --disabled-password --gecos "" knox
COPY ./Config/Hadoop/conf /usr/local/hadoop/etc/hadoop
COPY ./Config/Hadoop/http-signature.secret /etc/http-signature.secret
COPY ./Config/Hadoop/log4j.properties /usr/local/hadoop/etc/hadoop/log4j.properties
COPY --chmod=777 ./scripts/utils/myrun_scripts.sh /opt/bin/myrun_scripts
COPY --chmod=777 ./scripts/create-https-key.sh /opt/bin/https_key_init
COPY --chmod=777 ./scripts/kdc-keytabs-waiting.sh /opt/bin/kdc_waiting
COPY --chmod=777 ./scripts/utils/mywait.sh /opt/bin/mywait
COPY ./Config/Kerberos/krb5.conf /etc/krb5kdc/krb5.conf
ENV KRB5_CONFIG="/etc/krb5kdc/krb5.conf"
# https://stackoverflow.com/questions/33132768/kerberos-still-using-default-etc-krb5-conf-file-even-after-setting-krb5-config
ENV HADOOP_OPTS="$HADOOP_OPTS -Djava.security.krb5.conf=/etc/krb5kdc/krb5.conf"
ENV HADOOP_HOME="/usr/local/hadoop"
ENV HADOOP_COMMON_HOME="$HADOOP_HOME"
ENV HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop"
ENV HADOOP_HDFS_HOME="$HADOOP_HOME"
ENV HADOOP_MAPRED_HOME="$HADOOP_HOME"
ENV HADOOP_YARN_HOME="$HADOOP_HOME"
ENV HADOOP_OS_TYPE="Linux"
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="$PATH:/opt/bin:$HADOOP_HOME/bin:$JAVA_HOME/bin"
# https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html#Troubleshooting
ENV HADOOP_JAAS_DEBUG true
ENV HADOOP_OPTS "$HADOOP_OPTS -Djava.net.preferIPv4Stack=true -Dsun.security.krb5.debug=true -Dsun.security.spnego.debug"

# LDAP-сервер
FROM ubuntu AS ldap-server
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update 
RUN apt install -y expect
RUN apt install -y ca-certificates
RUN apt install -y gnutls-bin ssl-cert rsyslog schema2ldif
COPY --chmod=777 ./scripts/utils/myrun_scripts.sh /opt/bin/myrun_scripts
COPY --chmod=777 ./scripts/ldap-server/setup.sh /opt/bin/
COPY --chmod=777 ./scripts/ldap-server/setup.exp /opt/bin/setup
COPY --chmod=777 ./scripts/ldap-server/create-ranger-users.sh /scripts/a.sh
COPY ./Config/Kerberos/kerberos.schema /tmp/
VOLUME [ "/etc/CA" ]
VOLUME [ "/etc/sync" ]
ENV PATH="$PATH:/opt/bin/"
ENTRYPOINT [ "/bin/bash", "-c", "rm -f /etc/sync/ldap_started && \
                                setup && rsyslogd && slapd '-h ldaps:///' && \
                                myrun_scripts && \
                                touch /etc/sync/ldap_started && \
                                tail -f /var/log/syslog"]

# KERBEROS-сервер
FROM ubuntu AS kdc-server
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update 
RUN apt install -y expect 
RUN apt install -y ca-certificates
COPY --chmod=777 ./scripts/utils/myrun_scripts.sh /opt/bin/myrun_scripts
COPY --chmod=777 ./scripts/kdc-server/setup.sh /opt/bin/
COPY --chmod=777 ./scripts/kdc-server/setup.exp /opt/bin/setup
# COPY --chmod=777 ./scripts/utils/mywait.sh /opt/bin/mywait
COPY ./Config/Kerberos/krb5.conf /tmp/
COPY --chmod=777 ./scripts/kdc-server/create-hadoop-principals.sh /scripts/a.sh
COPY --chmod=777 ./scripts/kdc-server/kerberize-ranger-user.sh /scripts/b.sh
VOLUME [ "/etc/sync" ]
VOLUME [ "/etc/security/" ]
ENV PATH="$PATH:/opt/bin/"
ENTRYPOINT [ "/bin/bash", "-c", "rm -f /etc/sync/krb5kdc_started && \
                                setup && krb5kdc && kadmind && myrun_scripts && \
                                touch /etc/sync/krb5kdc_started && \
                                tail -f /var/log/krb5kdc.log" ]
                                # mywait krb5kdc kadmind" ]

# name-node
FROM hadoop-image AS hadoop-master
COPY ./Config/Ranger/hdfs/install.properties /tmp/hdfs/install.properties
COPY --chmod=777 ./scripts/name-node/filesystem-format.sh /opt/bin/hadoop_init
COPY --chmod=777 ./scripts/name-node/install-hdfs-plugin.sh /opt/bin/ranger_init
COPY --chmod=777 ./scripts/name-node/filesystem-init.sh /scripts/a.sh
COPY --chmod=777 ./Data/Ranger_distrib/ranger/target/ranger-2.5.1-SNAPSHOT-hdfs-plugin.tar.gz /usr/local/ranger-2.5.1-SNAPSHOT-hdfs-plugin.tar.gz
ENTRYPOINT [ "/bin/bash", "-c", "https_key_init && kdc_waiting && \
                                su -c '/opt/bin/hadoop_init' hdfs && \
                                ranger_init && \
                                su -c '/usr/local/hadoop/bin/hdfs --daemon start namenode' hdfs && \
                                myrun_scripts && mywait" ]

# resourse-manager
FROM hadoop-image AS hadoop-rmanager
COPY ./Config/Ranger/yarn/install.properties /tmp/yarn/install.properties
COPY --chmod=777 ./scripts/yarn/install-yarn-plugin.sh /opt/bin/ranger_init
COPY --chmod=777 ./Data/Ranger_distrib/ranger/target/ranger-2.5.1-SNAPSHOT-yarn-plugin.tar.gz /usr/local/ranger-2.5.1-SNAPSHOT-yarn-plugin.tar.gz
ENTRYPOINT [ "/bin/bash", "-c", "https_key_init && kdc_waiting && ranger_init && \
                                su -c '/usr/local/hadoop/bin/yarn --daemon start resourcemanager' yarn && \
                                mywait"]
                                # Ranger Plugin for yarn has been enabled. Please restart yarn to ensure that changes are effective.
# data-node and node-manager
FROM hadoop-image AS hadoop-worker
ENTRYPOINT [ "/bin/bash", "-c", "https_key_init && kdc_waiting && \
                                su -c '/usr/local/hadoop/bin/hdfs datanode &' hdfs && \
                                su -c '/usr/local/hadoop/bin/yarn nodemanager &' yarn && mywait" ]

# yarn-history
FROM hadoop-image AS hadoop-history
COPY --chmod=777 ./scripts/yarn-history/wait-for-directory.sh /opt/bin/test_directory
ENTRYPOINT [ "/bin/bash", "-c", "https_key_init && kdc_waiting && test_directory && \
                                su -c '/usr/local/hadoop/bin/mapred historyserver' mapred" ]

# Solr for ranger's audit
FROM ubuntu AS hadoop-solr
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update 
RUN apt install -y openjdk-11-jdk 
RUN apt install -y krb5-user
RUN apt install -y ca-certificates
RUN apt install -y lsof
RUN addgroup solr
RUN adduser --ingroup solr --disabled-password --gecos "" solr
COPY ./Config/Kerberos/krb5.conf /etc/krb5.conf
COPY --chmod=777 ./scripts/create-https-key.sh /opt/bin/https_key_init
COPY --chmod=777 ./scripts/kdc-keytabs-waiting.sh /opt/bin/kdc_waiting
COPY --chmod=777 ./scripts/utils/myrun_scripts.sh /opt/bin/myrun_scripts
# COPY --chmod=777 ./scripts/utils/mywait.sh /opt/bin/mywait
COPY ./Data/Ranger_distrib/ranger/security-admin/contrib/solr_for_audit_setup/conf/solrconfig.xml /tmp/solr/schema/solrconfig.xml
COPY ./Data/Ranger_distrib/ranger/security-admin/contrib/solr_for_audit_setup/conf/managed-schema /tmp/solr/schema/schema.xml
ADD https://archive.apache.org/dist/lucene/solr/8.4.1/solr-8.4.1.tgz /usr/local/
RUN tar zxf /usr/local/solr-8.4.1.tgz -C /usr/local
RUN ln -s /usr/local/solr-8.4.1 /usr/local/solr
COPY ./Config/Solr/solr.in.sh /usr/local/solr/bin/solr.in.sh
COPY ./Config/Solr/solr_jaas.conf /usr/local/solr/conf/solr_jaas.conf
COPY ./Config/Solr/security.json /usr/local/solr/server/solr
RUN chown solr:solr -R /usr/local/solr/
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
ENV PATH="$PATH:/opt/bin/"
ENTRYPOINT [ "/bin/bash", "-c", "https_key_init && kdc_waiting && \
                                su -c '/usr/local/solr/bin/solr start' solr && \
                                su -c 'kinit -k -t /etc/security/keytabs/ranger.keytab rangeradmin/hadoop-ranger.docker.net@DOCKER.NET' solr && \
                                su -c '/usr/local/solr/bin/solr create_core -c ranger_audits -d /tmp/solr/schema' solr && \
                                su -c 'kdestroy' solr && \
                                tail -f /usr/local/solr/server/logs/solr.log" ]

# Ranger-admin with ranger-usersync
FROM ubuntu AS hadoop-ranger
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update 
RUN apt install -y openjdk-8-jdk 
RUN apt install -y krb5-user
RUN apt install -y ca-certificates
RUN apt install -y libpostgresql-jdbc-java 
RUN apt install -y lsb-release
RUN apt install -y bc
RUN apt install -y python3
RUN ln -sf /usr/bin/python3 /usr/bin/python
COPY ./Config/Kerberos/krb5.conf /etc/krb5.conf
COPY --chmod=777 ./scripts/create-https-key.sh /opt/bin/https_key_init
COPY --chmod=777 ./scripts/kdc-keytabs-waiting.sh /opt/bin/kdc_waiting
COPY --chmod=777 ./scripts/utils/myrun_scripts.sh /opt/bin/myrun_scripts
COPY --chmod=777 ./scripts/utils/mywait.sh /opt/bin/mywait
COPY ./Config/Ranger/admin/ /tmp/admin/
COPY ./Config/Ranger/usersync/ /tmp/usersync/
COPY --chown=root:root --chmod=777 ./scripts/ranger/init.sh /opt/bin/setup
COPY ./Data/Ranger_distrib/ranger/target/ranger-2.5.1-SNAPSHOT-admin.tar.gz /usr/local/
COPY ./Data/Ranger_distrib/ranger/target/ranger-2.5.1-SNAPSHOT-usersync.tar.gz /usr/local/
COPY ./Config/Hadoop/conf /usr/local/hadoop/etc/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
ENV PATH="$PATH:/opt/bin/"
ENV HADOOP_HOME=/usr/local/hadoop
ENTRYPOINT [ "/bin/bash", "-c", "https_key_init && kdc_waiting && setup && mywait" ]
                            # && tail -f /var/log/ranger/usersync/usersync-hadoop-ranger.docker.net-.log" ]
                            # && sleep infinity" ]

# apache knox
FROM ubuntu AS hadoop-knox
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update 
RUN apt install -y openjdk-8-jdk 
RUN apt install -y krb5-user
RUN apt install -y ca-certificates
RUN apt install -y unzip
RUN apt install -y xmlstarlet
RUN addgroup knox
RUN adduser --ingroup knox --disabled-password --gecos "" knox
ADD https://dlcdn.apache.org/knox/2.0.0/knox-2.0.0.zip /usr/local
RUN unzip /usr/local/knox-2.0.0.zip -d /usr/local
RUN ln -s /usr/local/knox-2.0.0 /usr/local/knox
RUN chown knox:knox -R /usr/local/knox/
COPY ./Config/Kerberos/krb5.conf /etc/krb5.conf
COPY ./Config/Hadoop/conf /usr/local/hadoop/etc/hadoop
COPY --chmod=777 ./scripts/create-https-key.sh /opt/bin/https_key_init
COPY --chmod=777 ./scripts/kdc-keytabs-waiting.sh /opt/bin/kdc_waiting
COPY --chmod=777 ./scripts/utils/myrun_scripts.sh /opt/bin/myrun_scripts
COPY --chmod=777 ./scripts/utils/mywait.sh /opt/bin/mywait
COPY --chmod=777 ./scripts/knox/init.sh /opt/bin/setup
COPY ./Config/Knox/myproxy.xml /tmp
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH="$PATH:/opt/bin/"
ENV GATEWAY_HOME=/usr/local/knox
ENTRYPOINT [ "/bin/bash", "-c", "https_key_init && kdc_waiting && setup && \
                                # su -c '/usr/local/knox/bin/knoxcli.sh create-master --master hadoop' knox && \
                                # su -c './usr/local/knox/bin/gateway.sh start' knox && \
                                sleep infinity && \
                                mywait" ]

# client in mozilla
FROM alpine AS hadoop-client
RUN apk add firefox p11-kit-trust fontconfig ttf-freefont font-noto terminus-font krb5 ca-certificates curl
COPY ./Config/Kerberos/krb5.conf /etc/krb5.conf
COPY --chown=root:root --chmod=700 ./scripts/client-start.sh /home/start.sh
VOLUME [ "/tmp/.X11-unix" ]
# ENV DISPLAY = host.docker.internal:0
# ENV DISPLAY=$DISPLAY
ENTRYPOINT [ "/bin/sh", "-c", "/home/start.sh" ]

# ranger-install container
# https://github.com/apache/ranger/blob/master/build_ranger_using_docker.sh#L59
FROM centos AS ranger-distrib
RUN mkdir /tools
WORKDIR /tools
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum install -y wget
RUN yum install -y git
RUN yum install -y gcc
RUN yum install -y bzip2 fontconfig
RUN yum install -y diffutils
RUN yum install -y python3
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
# COPY ./Data/Ranger_distrib/jdk-11.0.1 /usr/lib/jvm/java-11
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk/
# ENV JAVA_HOME /usr/lib/jvm/java-11
ENV PATH $JAVA_HOME/bin:$PATH
ADD https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz .
RUN tar xfz apache-maven-3.6.3-bin.tar.gz
RUN ln -sf /tools/apache-maven-3.6.3 /tools/maven
ENV  PATH /tools/maven/bin:$PATH
ENV MAVEN_OPTS "-Xmx2048m -XX:MaxPermSize=512m"
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64"
RUN chmod +x /usr/local/bin/gosu
RUN useradd -ms /bin/bash builder
RUN usermod -g root builder
RUN chmod -R 777 /tools
VOLUME [ "/ranger" ]
VOLUME [ "/.m2" ]
COPY --chmod=777 ./scripts/ranger-install/init.sh /scripts/init.sh
ENTRYPOINT [ "/scripts/init.sh" ]
