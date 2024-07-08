#!/bin/bash
#run with sudo

rm -r -f ./Data/

mkdir -p ./Data/NameNode
mkdir -p ./Data/Worker1
mkdir -p ./Data/Worker2

chmod 700 ./Data/NameNode
chmod 700 ./Data/Worker1
chmod 700 ./Data/Worker2

chown 1001:1001 -R ./Data/NameNode
chown 1001:1001 -R ./Data/Worker1
chown 1001:1001 -R ./Data/Worker2

mkdir -p ./Data/Postgres/Data
chmod 700 ./Data/Postgres/Data
chown 999:999 -R ./Data/Postgres/Data

xhost +
