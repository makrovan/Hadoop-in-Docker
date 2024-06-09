FROM makrov/hadoop-kdc-server as hadoop-kdc-server
VOLUME [ "/root/keytabs" ]
COPY --chmod=777 ./KDC/init-script.sh /tmp/
COPY --chmod=777 ./KDC/create-principals.sh /tmp/
CMD /tmp/init-script.sh

FROM makrov/hadoop-image as hadoop-image
COPY ./Common/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
COPY ./Common/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh
COPY ./Common/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
COPY ./Common/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
COPY ./Common/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
COPY ./Common/ssl-server.xml /usr/local/hadoop/etc/hadoop/ssl-server.xml
COPY ./Common/http-signature.secret /etc/http-signature.secret
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV HADOOP_HOME=/usr/local/hadoop/

FROM hadoop-image as hadoop-master
USER hdfs
COPY --chmod=777 ./NameNode/init-script.sh /tmp/
COPY --chmod=777 ./NameNode/init-filesystem.sh /tmp/
CMD /tmp/init-script.sh

FROM hadoop-image as hadoop-rmanager
USER yarn
ENTRYPOINT [ "/usr/local/hadoop/bin/yarn", "resourcemanager"]

FROM hadoop-image as hadoop-worker
COPY --chown=root:root --chmod=700 ./Worker/init-script.sh /root/init-script.sh
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
COPY --chown=root:root --chmod=700 ./client-start.sh /home/start.sh
ENTRYPOINT [ "/home/start.sh" ]