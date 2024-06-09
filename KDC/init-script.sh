#!/bin/bash

slapd -h "ldap:// ldapi:// ldaps://"
krb5kdc
# kadmind
# wait /tmp/create-principals.sh
/tmp/create-principals.sh

kadmind -nofork