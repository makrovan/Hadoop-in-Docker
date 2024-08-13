#!/bin/bash

krb5kdc
while [ $? -ne 0 ]
do
    sleep 5
    echo "waiting krb5kdc..."
    krb5kdc
done
/tmp/create-principals.sh
kadmind -nofork