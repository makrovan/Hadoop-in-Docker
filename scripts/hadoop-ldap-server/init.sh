#!/bin/bash

echo "ldap starting..."
rsyslogd
slapd -h "ldaps://" -d 0