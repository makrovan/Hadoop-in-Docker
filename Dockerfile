FROM makrov/hadoop-ldap-server AS hadoop-ldap-server
VOLUME [ "/etc/krb5kdc/keyfiles" ]
COPY --chmod=777 ./init-scripts/ldap-init-script.sh /tmp/
ENTRYPOINT [ "/tmp/ldap-init-script.sh" ]

FROM makrov/hadoop-kdc-server AS hadoop-kdc-server
VOLUME [ "/root/keytabs" ]
VOLUME [ "/etc/krb5kdc/keyfiles" ]
COPY --chmod=777 ./init-scripts/kdc-create-principals.sh /tmp/
COPY --chmod=777 ./init-scripts/kdc-init-script.sh /tmp/
ENTRYPOINT [ "/tmp/kdc-init-script.sh" ]

FROM makrov/hadoop-image AS hadoop-image
COPY ./Config/Hadoop/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
COPY ./Config/Hadoop/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh
COPY ./Config/Hadoop/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
COPY ./Config/Hadoop/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
COPY ./Config/Hadoop/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
COPY ./Config/Hadoop/ssl-server.xml /usr/local/hadoop/etc/hadoop/ssl-server.xml
COPY ./Config/Hadoop/http-signature.secret /etc/http-signature.secret
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV HADOOP_HOME=/usr/local/hadoop/

FROM hadoop-image AS hadoop-master
USER hdfs
COPY --chmod=777 ./init-scripts/nn-init-script.sh /tmp/init-script.sh
COPY --chmod=777 ./init-scripts/nn-init-filesystem.sh /tmp/init-filesystem.sh
ENTRYPOINT [ "/tmp/init-script.sh" ]

FROM hadoop-image AS hadoop-rmanager
USER yarn
ENTRYPOINT [ "/usr/local/hadoop/bin/yarn", "resourcemanager"]

FROM hadoop-image AS hadoop-worker
COPY --chown=root:root --chmod=777 ./init-scripts/worker-init-script.sh /root/init-script.sh
ENTRYPOINT [ "/root/init-script.sh" ]

FROM hadoop-image AS hadoop-history
USER mapred
ENTRYPOINT [ "/usr/local/hadoop/bin/mapred", "historyserver"]

FROM alpine AS hadoop-client
VOLUME [ "/tmp/.X11-unix" ]
VOLUME [ "/etc/security/keytab/" ]
# ENV DISPLAY = host.docker.internal:0
# ENV DISPLAY=$DISPLAY
RUN apk add firefox fontconfig ttf-freefont font-noto terminus-font krb5
COPY ./Config/Kerberos/krb5.conf /etc/krb5.conf
COPY --chown=root:root --chmod=700 ./init-scripts/client-start.sh /home/start.sh
ENTRYPOINT [ "/home/start.sh" ]

FROM ubuntu AS java-image
ARG DEBIAN_FRONTEND=noninteractive
# https://stackoverflow.com/questions/24991136/docker-build-could-not-resolve-archive-ubuntu-com-apt-get-fails-to-install-a
RUN apt-get update && apt-get install -y openjdk-8-jdk libpostgresql-jdbc-java krb5-user
COPY ./Config/Kerberos/krb5.conf /etc/krb5.conf
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

FROM java-image AS hadoop-solr
RUN apt-get update && apt-get install -y wget lsof
COPY ./Common/solr_for_audit_setup.tgz /usr/local
COPY ./Config/Solr/install.properties /tmp/install.properties
COPY --chmod=777 ./init-scripts/solr-init-script.sh /tmp/init-script.sh
ENTRYPOINT [ "/tmp/init-script.sh" ]

FROM java-image AS hadoop-ranger
RUN apt-get update && apt-get install -y python3
VOLUME [ "/etc/security/keytab/" ]
VOLUME [ "/etc/hadoop/conf" ]
COPY ./Common/ranger-2.4.0-admin.tar.gz /usr/local/ranger-2.4.0-admin.tar.gz
COPY ./Config/Ranger/install.properties /tmp/install.properties
COPY --chown=root:root --chmod=777 ./init-scripts/ranger-init-script.sh /tmp/init-script.sh
ENTRYPOINT [ "/tmp/init-script.sh" ]