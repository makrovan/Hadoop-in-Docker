#!/bin/bash
set -x

# ждем kdc
while [ ! -f /etc/sync/krb5kdc_started ]
do
    sleep 5
    echo "waiting /etc/sync/krb5kdc_started..."
done
