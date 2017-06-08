#!/bin/bash

set -ex

#docker create --name undercloud-volumes \
#  -v tmp:/tmp \
#  -v etc-puppet:/etc/puppet \
#  -v etc-ssh:/etc/ssh \
#  -v kolla:/var/lib/kolla \
#  -v docker-puppet:/var/lib/docker-puppet \
#  -v config-data:/var/lib/config-data \
#  -v var-run:/var/run \
#   flaper87/tripleo-undercloud-init-container 

#docker run --net=host --privileged --name docker-daemon --volumes-from undercloud-volumes -d docker:dind --storage-driver=overlay

docker create --name undercloud-volumes \
  -v /tmp:/tmp \
  -v /etc/hosts:/etc/hosts \
  -v /etc/puppet:/etc/puppet \
  -v /etc/ssh:/etc/ssh \
  -v /var/lib/kolla:/var/lib/kolla \
  -v /var/lib/docker-puppet:/var/lib/docker-puppet \
  -v /var/lib/config-data:/var/lib/config-data \
  -v /var/run:/var/run \
   flaper87/tripleo-undercloud-init-container 


ID=`cat /proc/self/cgroup | grep -o  -e "docker-.*.scope" | head -n 1 | sed "s/docker-\(.*\).scope/\\1/"`

#       -v /var/run/docker.sock:/var/run/docker.sock \
docker run -d --name undercloud-deploy --user root --net=host --privileged \
       --volumes-from $ID \
       --volumes-from undercloud-volumes \
       -ti flaper87/tripleo-undercloud-init-container /root/deploy.sh
