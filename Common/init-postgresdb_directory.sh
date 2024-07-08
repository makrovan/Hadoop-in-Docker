#!/bin/bash
#run with sudo

rm -r -f ./Data/Postgres

mkdir -p ./Data/Postgres/Data
chmod 700 ./Data/Postgres/Data
chown 999:999 -R ./Data/Postgres/Data