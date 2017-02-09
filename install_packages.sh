#!/bin/bash

set -ex

yum install -y \
    git \
    vim \
    sudo \
    docker

# Remove unnecessary packages
yum autoremove -y
yum clean all
