#!/bin/bash

set -ex

docker run --name undercloud-deploy --net=host --privileged \
-v /tmp:/tmp \
-v /var/lib/docker-puppet.json:/var/lib/docker-puppet.json \
-v /var/lib/docker-puppet-tasks1.json:/var/lib/docker-puppet-tasks1.json \
-v /var/lib/docker-puppet-tasks2.json:/var/lib/docker-puppet-tasks2.json \
-v /var/lib/docker-puppet-tasks3.json:/var/lib/docker-puppet-tasks3.json \
-v /var/lib/docker-puppet-tasks4.json:/var/lib/docker-puppet-tasks4.json \
-v /var/lib/docker-puppet-tasks5.json:/var/lib/docker-puppet-tasks5.json \
-v /var/lib/docker-puppet:/var/lib/docker-puppet \
-v /var/lib/config-data:/var/lib/config-data \
-v /var/run/docker.sock:/var/run/docker.sock \
-ti tripleo-undercloud-init-container /root/deploy.sh
