FROM makrov/hadoop-ldap-server as hadoop-ldap-server
VOLUME [ "/etc/krb5kdc/keyfiles" ]
COPY --chmod=777 ./init-scripts/ldap-init-script.sh /tmp/
ENTRYPOINT [ "/tmp/ldap-init-script.sh" ]

FROM makrov/hadoop-kdc-server as hadoop-kdc-server
VOLUME [ "/root/keytabs" ]
VOLUME [ "/etc/krb5kdc/keyfiles" ]
COPY --chmod=777 ./init-scripts/kdc-create-principals.sh /tmp/
COPY --chmod=777 ./init-scripts/kdc-init-script.sh /tmp/
ENTRYPOINT [ "/tmp/kdc-init-script.sh" ]

FROM makrov/hadoop-image as hadoop-image
COPY ./Hadoop/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
COPY ./Hadoop/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh
COPY ./Hadoop/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
COPY ./Hadoop/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
COPY ./Hadoop/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
COPY ./Hadoop/ssl-server.xml /usr/local/hadoop/etc/hadoop/ssl-server.xml
COPY ./Hadoop/http-signature.secret /etc/http-signature.secret
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV HADOOP_HOME=/usr/local/hadoop/

FROM hadoop-image as hadoop-master
USER hdfs
COPY --chmod=777 ./init-scripts/nn-init-script.sh /tmp/init-script.sh
COPY --chmod=777 ./init-scripts/nn-init-filesystem.sh /tmp/init-filesystem.sh
CMD /tmp/init-script.sh

FROM hadoop-image as hadoop-rmanager
USER yarn
ENTRYPOINT [ "/usr/local/hadoop/bin/yarn", "resourcemanager"]

FROM hadoop-image as hadoop-worker
COPY --chown=root:root --chmod=777 ./init-scripts/worker-init-script.sh /root/init-script.sh
ENTRYPOINT [ "/root/init-script.sh" ]

FROM hadoop-image as hadoop-history
USER mapred
ENTRYPOINT [ "/usr/local/hadoop/bin/mapred", "historyserver"]

FROM alpine as hadoop-client
VOLUME [ "/tmp/.X11-unix" ]
VOLUME [ "/etc/security/keytab/" ]
ENV DISPLAY=host.docker.internal:0
RUN apk add firefox fontconfig ttf-freefont font-noto terminus-font krb5
COPY ./Common/krb5.conf /etc/krb5.conf
COPY --chown=root:root --chmod=700 ./init-scripts/client-start.sh /home/start.sh
ENTRYPOINT [ "/home/start.sh" ]