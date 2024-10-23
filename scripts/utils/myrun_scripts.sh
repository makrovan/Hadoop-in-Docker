#!/bin/bash
set -x

for SCRIPT in /scripts/*; do
    if [ -f $SCRIPT -a -x $SCRIPT ]; then
        $SCRIPT
    fi
done