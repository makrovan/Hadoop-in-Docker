FROM makrov/hadoop-image
COPY ./Common/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
COPY ./Common/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh
COPY ./Common/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
COPY ./Common/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
COPY ./Common/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
COPY ./Common/ssl-server.xml /usr/local/hadoop/etc/hadoop/ssl-server.xml
COPY ./Common/http-signature.secret /etc/http-signature.secret
#COPY ./Common/krb5.conf /etc/krb5.conf
#COPY ./Common/log4j.properties /usr/local/hadoop/etc/hadoop/log4j.properties

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV HADOOP_HOME=/usr/local/hadoop/

USER yarn
# EXPOSE 9090 через hadoop-client
ENTRYPOINT [ "/usr/local/hadoop/bin/yarn", "proxyserver"]