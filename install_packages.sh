#!/bin/bash

set -ex

yum install -y \
    glibc-common \
    initscripts \
    systemd \
    git \
    dhclient \
    ethtool \
    jq \
    vim \
    sudo \
    docker \
    git-review \
    openstack-heat-api \
    openstack-heat-engine \
    python-heat-agent-docker-cmd \
    python-heat-agent-hiera \
    python-heat-agent-apply-config \
    python-heat-agent-puppet \
    python-ipaddr python-tripleoclient

# Remove unnecessary packages
yum autoremove -y
yum clean all
