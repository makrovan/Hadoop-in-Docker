#!/bin/bash

sudo rm -r -f ./Data/

mkdir -p ./Data/NameNode
mkdir -p ./Data/Worker1
mkdir -p ./Data/Worker2

chmod 700 ./Data/NameNode
chmod 700 ./Data/Worker1
chmod 700 ./Data/Worker2

sudo chown 101000:101000 -R ./Data/NameNode
sudo chown 101000:101000 -R ./Data/Worker1
sudo chown 101000:101000 -R ./Data/Worker2

# xhost + ${localhost}