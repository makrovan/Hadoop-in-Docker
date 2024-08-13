#!/bin/bash

# rm -r -f ./Data/NameNode
# rm -r -f ./Data/Worker1
# rm -r -f ./Data/Worker2

mkdir -p ./Data/NameNode
mkdir -p ./Data/Worker1
mkdir -p ./Data/Worker2

chmod 700 ./Data/NameNode
chmod 700 ./Data/Worker1
chmod 700 ./Data/Worker2

chown 1001:1001 -R ./Data/NameNode
chown 1001:1001 -R ./Data/Worker1
chown 1001:1001 -R ./Data/Worker2

xhost +