#!/bin/bash

set -ex

cd /root

git clone https://github.com/dprince/undercloud_containers
pushd undercloud_containers
sh doit.sh
popd

sudo rm -Rf /usr/lib/python2.7/site-packages/heat/
git clone git://git.openstack.org/openstack/heat
pushd heat 
sudo python setup.py install
popd

#pushd tripleo-heat-templates
#git fetch https://git.openstack.org/openstack/tripleo-heat-templates refs/changes/85/439585/2 && git cherry-pick FETCH_HEAD
#popd

sudo rm -Rf /etc/puppet/modules/*
sudo cp -rf /usr/share/openstack-puppet/modules/* /etc/puppet/modules/

# Puppet Ironic (this is required for dprince who needs to customize
# Ironic configs via ExtraConfig settings.)
pushd /etc/puppet/modules
rm -Rf tripleo
git clone git://git.openstack.org/openstack/puppet-tripleo tripleo
popd

cat > tripleo-heat-templates/environments/undercloud.yaml <<-EOF_CAT
resource_registry:
  OS::TripleO::Network::Ports::RedisVipPort: ../network/ports/noop.yaml
  OS::TripleO::Network::Ports::ControlPlaneVipPort: ../deployed-server/deployed-neutron-port.yaml
  OS::TripleO::Undercloud::Net::SoftwareConfig: ../net-config-noop.yaml
  OS::TripleO::NodeExtraConfigPost: ../extraconfig/post_deploy/undercloud_post.yaml

parameter_defaults:
  StackAction: CREATE
  SoftwareConfigTransport: POLL_SERVER_HEAT
  NeutronTunnelTypes: []
  NeutronBridgeMappings: ctlplane:br-ctlplane
  NeutronAgentExtensions: []
  NeutronFlatNetworks: '*'
  NovaSchedulerAvailableFilters: 'tripleo_common.filters.list.tripleo_filters'
  NovaSchedulerDefaultFilters: ['RetryFilter', 'TripleOCapabilitiesFilter', 'ComputeCapabilitiesFilter', 'AvailabilityZoneFilter', 'RamFilter', 'DiskFilter', 'ComputeFilter', 'ImagePropertiesFilter', 'ServerGroupAntiAffinityFilter', 'ServerGroupAffinityFilter']
  NeutronDhcpAgentsPerNetwork: 2
  HeatConvergenceEngine: false
  HeatMaxResourcesPerStack: -1
EOF_CAT

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
    - OS::TripleO::Services::RabbitMQ
    - OS::TripleO::Services::GlanceApi
    - OS::TripleO::Services::SwiftProxy
    - OS::TripleO::Services::SwiftStorage
    - OS::TripleO::Services::SwiftRingBuilder
    - OS::TripleO::Services::Memcached
    - OS::TripleO::Services::HeatApi
    - OS::TripleO::Services::HeatApiCfn
    - OS::TripleO::Services::HeatEngine
    - OS::TripleO::Services::NovaApi
#    - OS::TripleO::Services::NovaPlacement
    - OS::TripleO::Services::NovaMetadata
    - OS::TripleO::Services::NovaScheduler
    - OS::TripleO::Services::NovaConductor
    - OS::TripleO::Services::MistralEngine
    - OS::TripleO::Services::MistralApi
    - OS::TripleO::Services::MistralExecutor
    - OS::TripleO::Services::IronicApi
    - OS::TripleO::Services::IronicConductor
    - OS::TripleO::Services::IronicPxe
    - OS::TripleO::Services::NovaIronic
    - OS::TripleO::Services::Zaqar
    - OS::TripleO::Services::NeutronApi
    - OS::TripleO::Services::NeutronCorePlugin
#    - OS::TripleO::Services::NeutronOvsAgent
    - OS::TripleO::Services::NeutronDhcpAgent
EOF_CAT


LOCAL_IP=${LOCAL_IP:-`/usr/sbin/ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n'`}

cat > $HOME/run.sh <<-EOF_CAT
time sudo openstack undercloud deploy --templates=$HOME/tripleo-heat-templates \
--local-ip=$LOCAL_IP \
--keep-running \
--heat-native \
-e $HOME/tripleo-heat-templates/environments/services/ironic.yaml \
-e $HOME/tripleo-heat-templates/environments/services/mistral.yaml \
-e $HOME/tripleo-heat-templates/environments/services/zaqar.yaml \
-e $HOME/tripleo-heat-templates/environments/docker.yaml \
-e $HOME/tripleo-heat-templates/environments/mongodb-nojournal.yaml \
-e $HOME/custom.yaml
EOF_CAT
chmod 755 $HOME/run.sh

sh run.sh
