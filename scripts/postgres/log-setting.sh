#!/bin/bash
set -x
cd /var/lib/postgresql/data

# https://www.postgresql.org/docs/current/runtime-config-logging.html
sed -i 's/#logging_collector = off/logging_collector = on/g' postgresql.conf
sed -i 's/#log_min_messages = warning/log_min_messages = debug5/g' postgresql.conf
sed -i 's/#log_min_error_statement = error/log_min_error_statement = debug5/g' postgresql.conf
sed -i 's/#log_connections = off/log_connections = on/g' postgresql.conf
sed -i 's/#log_disconnections = off/log_disconnections = on/g' postgresql.conf
sed -i 's/#log_error_verbosity = default/log_error_verbosity = verbose/g' postgresql.conf
sed -i "s/#log_statement = 'none'/log_statement = 'all'/g" postgresql.conf
