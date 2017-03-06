#!/bin/bash

set -ex

yum -y install epel-release
yum install -y https://dprince.fedorapeople.org/tmate-2.2.1-1.el7.centos.x86_64.rpm
curl -L -o /etc/yum.repos.d/delorean-deps.repo  http://trunk.rdoproject.org/centos7/delorean-deps.repo
sed -i -e 's|priority=.*|priority=30|' /etc/yum.repos.d/delorean-deps.repo
curl -L -o /etc/yum.repos.d/delorean.repo http://trunk.rdoproject.org/centos7/current/delorean.repo

yum -y update

yum install -y \
    git \
    vim \
    sudo \
    docker \
    python-dev \
    python-setuptools \
    curl vim-enhanced telnet 

yum install -y \
  python-heat-agent \
  python-heat-agent-hiera \
  python-heat-agent-apply-config \
  python-heat-agent-puppet python-ipaddr \
  python-tripleoclient \
  python-heat-agent-docker-cmd \
  docker \
  openvswitch \
  openstack-heat-monolith \
  openstack-heat-api \
  openstack-heat-engine \
  openstack-puppet-modules

# Remove unnecessary packages
yum autoremove -y
yum clean all
