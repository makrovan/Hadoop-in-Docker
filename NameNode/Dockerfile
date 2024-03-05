FROM makrov/hadoop-image
COPY ./Common/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
COPY ./Common/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh
COPY ./Common/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
COPY ./Common/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
COPY ./Common/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
COPY ./Common/ssl-server.xml /usr/local/hadoop/etc/hadoop/ssl-server.xml
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV HADOOP_HOME=/usr/local/hadoop/
USER hdfs
COPY --chmod=777 ./NameNode/init-script.sh /tmp/
# EXPOSE 9870 9871
EXPOSE 9871
CMD /tmp/init-script.sh