#!/bin/bash

set -ex

cd /root

git clone https://github.com/dprince/undercloud_containers
pushd undercloud_containers
sh doit.sh
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
EOF_CAT


sh run.sh
