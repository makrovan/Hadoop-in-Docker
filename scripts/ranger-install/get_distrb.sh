#!/bin/bash

# set -x
rm -rf ../../Data/Ranger_distrib/ranger
cd ../../Data/Ranger_distrib
# sudo chown -R user:user .m2/
mkdir .m2
chmod -R 777 .m2
# git clone https://github.com/apache/ranger
git clone https://gitbox.apache.org/repos/asf/ranger.git
