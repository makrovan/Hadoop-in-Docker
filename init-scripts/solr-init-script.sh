#!/bin/bash

cd /usr/local
tar xvf solr_for_audit_setup.tgz
cd /usr/local/solr_for_audit_setup
cp -f /tmp/install.properties .

# https://cwiki.apache.org/confluence/display/RANGER/Install+and+Configure+Solr+for+Ranger+Audits+-+Apache+Ranger+0.5
# cd /usr/local
# git clone https://github.com/apache/incubator-ranger.git
# cd incubator-ranger/security-admin/contrib/solr_for_audit_setup
# cp -f /tmp/install.properties .
# solr_for_audit_setup.tgz got from ranger_dev

./setup.sh
su - solr /opt/solr/ranger_audit_server/scripts/start_solr.sh

pid="$(pidof java)"
while [ -e /proc/$pid ]; do sleep 5; done