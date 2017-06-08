#!/bin/bash

set -ex

ssh-keygen -A

cd /root

# FIXME: We need paunch until RDO gets us an RPM built
cd
git clone git://git.openstack.org/openstack/paunch
cd paunch
sudo python setup.py install

cd
git clone git://git.openstack.org/openstack/tripleo-heat-templates
cd tripleo-heat-templates

# PUT PATCHES HERE
cd

mkdir -p /var/lib/{docker-puppet,config-data}
mkdir -p /etc/puppet/{modules,hieradata}
rm -Rf /etc/puppet/modules/*
cp -rf /usr/share/openstack-puppet/modules/* /etc/puppet/modules/

# Puppet Ironic (this is required for dprince who needs to customize
# Ironic configs via ExtraConfig settings.)
pushd /etc/puppet/modules
rm -Rf tripleo
git clone git://git.openstack.org/openstack/puppet-tripleo tripleo
popd

cat > $HOME/tripleo-undercloud-passwords.yaml <<-EOF_CAT
parameter_defaults:
  AdminPassword: HnTzjCGP6HyXmWs9FzrdHRxMs
EOF_CAT

if [[ ! -f $HOME/custom.yaml ]]; then
cat > $HOME/custom.yaml <<-EOF_CAT
parameter_defaults:
  UndercloudNameserver: 8.8.8.8
  NeutronServicePlugins: ""
EOF_CAT
fi

LOCAL_IP=${LOCAL_IP:-`/usr/sbin/ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n'`}

ls /custom-environments
EXTRA_ENVS=''
for f in /custom-environments/*; do
    [ -e "$f" ] || continue
    EXTRA_ENVS="$EXTRA_ENVS -e $f";
done

cat > $HOME/run.sh <<-EOF_CAT
time sudo openstack undercloud deploy --templates=$HOME/tripleo-heat-templates \
--local-ip=$LOCAL_IP \
--keep-running \
--heat-native \
-e $HOME/tripleo-heat-templates/environments/services-docker/ironic.yaml \
-e $HOME/tripleo-heat-templates/environments/services-docker/mistral.yaml \
-e $HOME/tripleo-heat-templates/environments/services-docker/zaqar.yaml \
-e $HOME/tripleo-heat-templates/environments/docker.yaml \
-e $HOME/tripleo-heat-templates/environments/mongodb-nojournal.yaml \
-e $HOME/custom.yaml $EXTRA_ENVS
EOF_CAT
chmod 755 $HOME/run.sh

cat $HOME/run.sh
sh $HOME/run.sh
