FROM ubuntu AS ubuntu-with-expect
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y expect

FROM ubuntu-with-expect AS hadoop-ldap-server
VOLUME [ "/etc/krb5kdc/keyfiles" ]
COPY --chmod=777 ./scripts/hadoop-ldap-server/setup.sh /opt/
COPY --chmod=777 ./scripts/hadoop-ldap-server/setup.exp /opt/
COPY ./scripts/hadoop-ldap-server/kerberos.schema /tmp/
COPY --chmod=777 ./scripts/hadoop-ldap-server/init.sh /tmp/
ENTRYPOINT [ "/bin/bash", "-c", "/opt/setup.exp && /tmp/init.sh" ]

FROM ubuntu-with-expect AS hadoop-kdc-server
VOLUME [ "/root/keytabs" ]
VOLUME [ "/etc/krb5kdc/keyfiles" ]
COPY --chmod=777 ./scripts/hadoop-kdc-server/setup.sh /opt/
COPY --chmod=777 ./scripts/hadoop-kdc-server/setup.exp /opt/
COPY ./Config/Kerberos/krb5.conf /tmp/
COPY --chmod=777 ./scripts/hadoop-kdc-server/create-principals.sh /tmp/
COPY --chmod=777 ./scripts/hadoop-kdc-server/init.sh /tmp/
ENTRYPOINT [ "/bin/bash", "-c", "/opt/setup.exp && /tmp/init.sh" ]

FROM makrov/hadoop-image AS hadoop-image
VOLUME [ "/etc/security/keytab" ]
VOLUME [ "/etc/krb5kdc/keyfiles" ]
COPY ./Config/Hadoop/conf /usr/local/hadoop/etc/hadoop
COPY ./Config/Hadoop/http-signature.secret /etc/http-signature.secret
COPY --chmod=777 ./scripts/keystore-init.sh /root/keystore-init.sh
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV HADOOP_HOME=/usr/local/hadoop/

FROM hadoop-image AS hadoop-master
# USER hdfs
COPY --chmod=777 ./scripts/name-node/init.sh /tmp/init-script.sh
COPY --chmod=777 ./scripts/name-node/init-filesystem.sh /tmp/init-filesystem.sh
ENTRYPOINT [ "bash", "-c", "/root/keystore-init.sh && su -c /tmp/init-script.sh hdfs" ]

FROM hadoop-image AS hadoop-rmanager
# USER yarn
ENTRYPOINT [ "bash", "-c", "/root/keystore-init.sh && su -c \"/usr/local/hadoop/bin/yarn resourcemanager\" yarn"]

FROM hadoop-image AS hadoop-worker
COPY --chmod=777 ./scripts/worker-init.sh /root/init-script.sh
ENTRYPOINT [ "bash", "-c", "/root/keystore-init.sh && /root/init-script.sh" ]
# COPY --chmod=777 ./scripts/global-init.sh /tmp/
# ENTRYPOINT [ "/tmp/global-init.sh" ]

FROM hadoop-image AS hadoop-history
# USER mapred
ENTRYPOINT [ "bash", "-c", "/root/keystore-init.sh && su -c \"/usr/local/hadoop/bin/mapred historyserver\" mapred"]

FROM alpine AS hadoop-client
VOLUME [ "/tmp/.X11-unix" ]
VOLUME [ "/etc/security/keytab/" ]
VOLUME [ "/etc/krb5kdc/keyfiles" ]
# ENV DISPLAY = host.docker.internal:0
# ENV DISPLAY=$DISPLAY
# RUN apk add firefox fontconfig ttf-freefont font-noto terminus-font krb5
COPY ./Config/Kerberos/krb5.conf /etc/krb5.conf
COPY --chown=root:root --chmod=700 ./scripts/client-start.sh /home/start.sh
ENTRYPOINT [ "/bin/sh", "-c", "apk add firefox p11-kit-trust fontconfig ttf-freefont font-noto terminus-font krb5 ca-certificates curl && /home/start.sh" ]

# COPY --chmod=777 ./scripts/global-init.sh /tmp/
# ENTRYPOINT [ "/tmp/global-init.sh" ]

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
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk/
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

FROM ubuntu:20.04 AS java-image
ARG DEBIAN_FRONTEND=noninteractive
# https://stackoverflow.com/questions/24991136/docker-build-could-not-resolve-archive-ubuntu-com-apt-get-fails-to-install-a
RUN apt-get update && apt-get install -y openjdk-8-jdk libpostgresql-jdbc-java krb5-user
COPY ./Config/Kerberos/krb5.conf /etc/krb5.conf
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

FROM java-image AS hadoop-solr
RUN apt-get update && apt-get install -y wget lsof
VOLUME [ "/usr/local/solr_for_audit_setup" ]
COPY ./Config/Solr/install.properties /tmp/install.properties
COPY --chmod=777 ./scripts/solr/init.sh /scripts/init.sh
ENTRYPOINT [ "/scripts/init.sh" ]

FROM java-image AS hadoop-ranger
RUN apt-get update && apt-get install -y python
VOLUME [ "/etc/security/keytab/" ]
VOLUME [ "/etc/hadoop/conf" ]
VOLUME [ "/ranger/target" ]
# COPY ./Data/Ranger_distrib/ranger/target/ranger-2.4.0-admin.tar.gz /usr/local/ranger-2.4.0-admin.tar.gz
COPY ./Config/Ranger/admin/install.properties /tmp/admin/install.properties
# COPY ./Data/Ranger_distrib/ranger/target/ranger-2.4.0-usersync.tar.gz /usr/local/ranger-2.4.0-usersync.tar.gz
COPY ./Config/Ranger/usersync/install.properties /tmp/usersync/install.properties
COPY --chown=root:root --chmod=777 ./scripts/ranger/init.sh /scripts/init.sh
ENTRYPOINT [ "/scripts/init.sh" ]