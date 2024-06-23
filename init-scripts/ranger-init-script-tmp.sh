#!/bin/bash

apt update && apt install git maven bzip2 -y
# https://stackoverflow.com/questions/73004195/phantomjs-wont-install-autoconfiguration-error
export OPENSSL_CONF=/dev/null
sleep infinity&
wait $!