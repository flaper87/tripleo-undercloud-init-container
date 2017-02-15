#!/bin/bash

set -ex

docker run -d --name undercloud-deploy --net=host --privileged \
-v /tmp:/tmp \
-v /etc/puppet:/etc/puppet \
-v /var/lib/kolla:/var/lib/kolla \
-v /var/lib/docker-puppet:/var/lib/docker-puppet \
-v /var/lib/config-data:/var/lib/config-data \
-v /var/run/docker.sock:/var/run/docker.sock \
-ti flaper87/tripleo-undercloud-init-container /root/deploy.sh
