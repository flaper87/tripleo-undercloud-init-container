#!/bin/bash

set -ex

docker create --name undercloud-volumes \
  -v tmp:/tmp \
  -v etc-puppet:/etc/puppet \
  -v /usr/share/puppet:/usr/share/puppet \
  -v /usr/share/openstack-puppet:/usr/share/openstack-puppet \
  -v kolla:/var/lib/kolla \
  -v docker-puppet:/var/lib/docker-puppet \
  -v config-data:/var/lib/config-data \
  -v var-run:/var/run \
   flaper87/tripleo-undercloud-init-container 

docker run --net=host --privileged --name docker-daemon --volumes-from undercloud-volumes -d docker:dind --storage-driver=overlay

docker run -d --name undercloud-deploy --net=host --privileged \
       --volumes-from undercloud-volumes \
       -ti flaper87/tripleo-undercloud-init-container /root/deploy.sh
