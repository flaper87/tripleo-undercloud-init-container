#!/bin/bash

set -ex

cd /root

git clone https://github.com/dprince/undercloud_containers
pushd undercloud_containers
git checkout -b update-with-docker-puppet-dir origin/update-with-docker-puppet-dir
sh doit.sh
popd


# NOTE(flaper87): Install only a couple of services for now
cat > tripleo-heat-templates/roles_data_undercloud.yaml <<-EOF_CAT
- name: Undercloud # the 'primary' role goes first
  CountDefault: 1
  disable_constraints: True
  ServicesDefault:
    - OS::TripleO::Services::MySQL
    - OS::TripleO::Services::MongoDb
    - OS::TripleO::Services::Keystone
    - OS::TripleO::Services::Apache
    - OS::TripleO::Services::GlanceApi
EOF_CAT


sh run.sh
