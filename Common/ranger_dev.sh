#! /bin/bash
# docker rm $(docker ps -a -q) && docker rmi $(docker image ls -a -q)
# docker run -it --net=host centos /bin/bash

sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yum update -y
mkdir /tools
cd tools/
yum clean all
yum install -y wget
yum install -y git
yum install -y gcc
yum install -y bzip2 fontconfig
yum install -y diffutils
yum install -y python3
ln -s /usr/bin/python3 /usr/bin/python
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/
export PATH=$PATH:$JAVA_HOME/bin
wget https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
wget https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz.sha512
sha512sum  apache-maven-3.6.3-bin.tar.gz | cut -f 1 -d " " > tmp.sha1
cat apache-maven-3.6.3-bin.tar.gz.sha512 | cut -f 1 -d " " > tmp.sha1.download
diff -w tmp.sha1 tmp.sha1.download
tar -xzf apache-maven-3.6.3-bin.tar.gz
ln -sf /tools/apache-maven-3.6.3 /tools/maven
export PATH=$PATH:/tools/maven/bin
export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=512m"
export GOSU_VERSION=1.11
gpg --keyserver keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64"
curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc"
gpg --verify /usr/local/bin/gosu.asc
rm -f /usr/local/bin/gosu.asc
rm -rf /root/.gnupg/
chmod +x /usr/local/bin/gosu
#gosu nobody true
useradd -ms /bin/bash builder
usermod -g root builder
mkdir -p /scripts
echo "#! /bin/bash" > /scripts/mvn.sh
echo 'set -x; if [ "\$1" = "mvn" ]; then usermod -u \$(stat -c "%u" pom.xml) builder; gosu builder bash -c '"'"'ln -sf /.m2 \$HOME'"'"'; exec gosu builder "\$@"; fi; exec "\$@" ' >> /scripts/mvn.sh
chmod -R 777 /scripts
chmod -R 777 /tools

# docker ps -a
# docker container commit ee7 makrov/ranger_dev
# docker push makrov/ranger_dev

# sudo docker run --rm --net=host -v /home/user/Projects/apache-ranger-2.4.0:/ranger -w /ranger -v /root/.m2:/.m2 --name ranger_build makrov/ranger_dev mvn -Pall -DskipTests=true clean compile package install

# tar -cvzf solr_for_audit_setup.tgz ~/ranger/apache-ranger-2.4.0/security-admin/contrib/solr_for_audit_setup/