#!/bin/bash

set -ex

cd /root

git clone https://github.com/dprince/undercloud_containers
pushd undercloud_containers
git checkout -b update-with-docker-puppet-dir origin/update-with-docker-puppet-dir
sh doit.sh
popd
sh run.sh
