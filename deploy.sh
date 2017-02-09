#!/bin/bash

set -ex

cd /root

git clone https://github.com/dprince/undercloud_containers
pushd undercloud_containers
sh doit.sh
popd
sh run.sh
