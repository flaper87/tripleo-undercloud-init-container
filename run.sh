#!/bin/bash

set -ex

docker run --name undercloud-dind --privileged -d \
  -v /tmp \
  -v /etc/puppet \
  -v /var/lib/kolla \
  -v /var/lib/docker-puppet \
  -v /var/lib/config-data \
  docker:dind

docker run -d --name undercloud-deploy --net=host --privileged \
       --link undercloud-dind:docker \
       -e DOCKER_HOST=tcp://docker:2375 \
       --volumes-from undercloud-dind \
       -ti flaper87/tripleo-undercloud-init-container /root/deploy.sh
