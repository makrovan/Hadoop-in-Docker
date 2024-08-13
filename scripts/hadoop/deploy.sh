#!/bin/bash

echo "FROM ubuntu
ADD --chmod=777 setup.sh /opt/setup.sh
ADD --chmod=777 setup.exp /opt/setup.exp
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y expect" >> Dockerfile
docker build -t myhadoop .
docker run --name hadoop-image myhadoop /opt/setup.exp
docker container commit hadoop-image makrov/hadoop-image
docker push makrov/hadoop-image
rm Dockerfile
docker rm hadoop-image
docker rmi makrov/hadoop-image
docker rmi myhadoop

# docker run -it myhadoop /bin/bash