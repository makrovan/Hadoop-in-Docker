#!/bin/bash

sleep infinity&
wait $!

# ARG DEBIAN_FRONTEND=noninteractive
# export DEBIAN_FRONTEND=noninteractive 
# apt update -y
# apt install postgresql -y

# su postgres
# /usr/lib/postgresql/16/bin/initdb -D ~/pgsql/data
# /usr/lib/postgresql/16/bin/postgres -D ~/pgsql/data

# psql -U postgres -d postgres -c 'SHOW hba_file;'
# /var/lib/postgresql/data/pg_hba.conf

# cd /usr/local/ranger
# tar zxf ranger-2.4.0-admin.tar.gz
# ln -s ranger-2.4.0-admin ranger-admin
# cd ranger-admin