#!/bin/bash
set -x

if [ $(id -u) = 0 ]; then
    echo "Need root!"
    exit 1
fi

# https://docs.docker.com/engine/swarm/stack-deploy/

# Start nfs directory:
apt update
apt install -y nfs-kernel-server
# # on clients: 
# sudo apt install nfs-common
mkdir /share
# rm -r /share/Data
# mkdir -p /share/Data/CA
# mkdir -p /share/Data/KDC
# mkdir -p /share/Data/Sync
# mkdir -p /share/Data/KnoxPK

# ln -s /home/user/Projects/Hadoop-in-Docker/Data /share
# Grant full access to all users: 
echo "/share *(rw,async,no_subtree_check,no_root_squash)">>/etc/exports
exportfs -a
# sudo mount $(hostname):/share/Data /Data

# Start docker registry:
systemctl stop docker
echo '{"insecure-registries":["192.168.1.119:5000"]}' > /etc/docker/daemon.json
systemctl start docker
docker run -d -p 5000:5000 --name registry registry:2
# curl -X GET http://192.168.1.119:5000/v2/_catalog

# Start swarm:
LOCAL_IP=$(hostname -I | awk '{print $1}')
docker swarm init --advertise-addr $LOCAL_IP
docker node update --label-add TAG=manager $(hostname)
echo "Enter worker-node name:"
read WORKER_1
docker node update --label-add TAG=worker-1 $WORKER_1
# on manager:
# mkdir -p ~/Data/Postgres
# chown 999:999 -R ~/Data/Postgres 

# on worker:
# mkdir -p ~/Data/NameNode
# mkdir -p ~/Data/Worker1
# mkdir -p ~/Data/Worker2


docker compose up -d
docker compose down
dockr compose down --volumes
docker compose push

docker stack deploy --compose-file docker-compose.yml -d=false hadoopstack

# docker service ls
# docker node inspect $(hostname) | grep TAG
# docker node inspect $WORKER_1 | grep TAG
# docker exec -it <container-name-or-id> bash
# docker stack rm hadoopstack
# docker rm $(docker ps -a -q)
# docker rmi $(docker image ls -a -q)
# docker swarm leave --force
# docker system prune
exit 0