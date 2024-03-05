#!/bin/bash

krb5kdc
kadmind
/tmp/create-principals.sh

kadmind -nofork